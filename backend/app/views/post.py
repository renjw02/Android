#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib
import os, base64

from flask import Blueprint, jsonify, request, g
from .login_required import login_required
from app.services import PostService
from app.checkers import post_params_check, comment_params_check

bp = Blueprint('post', __name__, url_prefix='/api/post')

service = PostService()

@bp.route('/')
def index():
    return jsonify({'message': "post配置完成!"}), 200

# 创建帖子
@bp.route('/createpost', methods=['POST'])
@login_required
def create_post():
    try:    
        title = request.form.get('title')
        content = request.form.get('content')
        type = request.form.get('type')
        position = request.form.get('position')

        key, passed = post_params_check(title, content, type, position)
        if not passed:
            return jsonify({'message': "invalid arguments: " + key}), 400
        
        files = request.files.getlist('file')
        
        post, result = service.create_post(title, content, g.user_id, type, position)
        if files is not None:
            for file in files:
                filename = file.filename
                content_type = file.content_type

                if content_type.startswith('image'):
                    save_path = './static/images/'
                    path = os.path.join(save_path, filename)
                    pic, flag = service.upload_picture(post.id, path)
                    if not flag:
                        return jsonify({'message': "upload images falied"}), 400

                elif content_type.startswith('video'):
                    save_path = './static/videos/'
                    path = os.path.join(save_path, filename)
                    vid, flag = service.upload_video(post.id, path)
                    if not flag:
                        return jsonify({'message': "upload videos falied"}), 400
                
                file.save(path)

        if result:
            return jsonify({
                'postId': post.id,
                'userId': post.user_id,
                'title': post.title,
                'content': post.content,
                'message': "ok"
            }), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400

# 获取指定帖子信息
@bp.route('/getpost/<int:postId>', methods=['GET'])
@login_required
def get_post_detail(postId):
    try:        
        detail, result = service.get_post_detail(postId)
        images, has_picture = service.get_pictures(postId)
        videos, has_video = service.get_videos(postId)

        if result:
            images_data = []
            videos_data = []
            if has_picture:
                for image in images:
                    file = image['path']
                    if file.endswith('.jpg') or file.endswith('.jpeg') or file.endswith('.png'):
                        with open(file, 'rb') as f:
                            image_data = base64.b64encode(f.read()).decode('utf-8')
                            images_data.append(image_data)
            if has_video:
                for video in videos:
                    file = video['path']
                    if file.endswith('.mp4'):
                        with open(file, 'rb') as f:
                            video_data = base64.b64encode(f.read()).decode('utf-8')
                            videos_data.append(video_data)
                
            return jsonify({
                'message': "ok",
                'post': detail,
                'images': images_data,
                'videos': videos_data
                }), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400


# 获取一页的帖子列表
# 分类：全部、已关注用户、热门、类型
# 排序：发布时间、点赞数、评论数
# 可查看指定用户的发帖，置于用户个人页面
@bp.route('/getpostlist', methods=['GET'])
@login_required
def get_post_list():
    try:
        page = 1 if request.args.get('page') is None else int(request.args.get('page'))
        size = 10 if request.args.get('size') is None else int(request.args.get('size'))
        user_id = 0 if request.args.get('userId') is None else request.args.get('userId')
        order_by_what = None if request.args.get('orderByWhat') is None else request.args.get('orderByWhat')
        type = 0 if request.args.get('type') is None else int(request.args.get('type'))
        only_following = False if request.args.get('onlyFollowing') is None else True
        hot = False if request.args.get('hot') is None else True

        post_list, count, result = service.get_post_list(user_id, page, size, order_by_what, type, 
                                                        only_following, hot)

        # count 帖子总数
        if result:
            return jsonify({
                'posts': post_list,
                'page': page,
                'size': size,
                'total': count
            }), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400
        

# 修改指定帖子
@bp.route('/modifypost/<int:postId>', methods=['POST'])
@login_required
def modify_post(postId):
    try:
        content = request.get_json()
        if content is None:
            return jsonify({'message': "no content"}), 400
        key, passed = post_params_check(content)
        if not passed:
            return jsonify({'message': "invalid arguments: " + key}), 400

        check = service.check_post(postId, g.user_id)
        if not check:
            return jsonify({'message': "not found"}), 404

        result = service.update_post(content['title'], content['content'], postId, content['position'])

        if result:
            return jsonify({'message': "ok"}), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400


# 删除指定帖子
@bp.route('/deletepost/<int:postId>', methods=['POST'])
@login_required
def delete_post(postId):
    try:
        check = service.check_post(postId, g.user_id)
        if not check:
            return jsonify({'message': "not found"}), 404

        # post, flag = service.get_post_detail(postId)
        # if not flag: 
        #     return jsonify({'message': "not found"}), 404
        
        # id_list = []
        # for comment in post['comment']:
        #     id_list.append(comment['id'])

        # for id in id_list:
        #     flag = service.delete_comment(id)
        #     if not flag:
        #         return jsonify({'message': "delete error"}), 400
        #     # id_list = list(map(lambda x:x-1, id_list))

        result = service.delete_post(postId)

        if result:
            return jsonify({'message': "ok"}), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400


# 回复帖子
@bp.route('/createcomment/<int:postId>', methods=['POST'])
@login_required
def comment_post(postId):
    try:
        content = request.get_json()
        if content is None:
            return jsonify({'message': "no content"}), 400

        key, passed = comment_params_check(content)
        if not passed:
            return jsonify({'message': "invalid arguments: " + key}), 400
        if "commentId" in content:
            comment_id = content['commentId']
        else:
            comment_id = 0

        # 检查回复是否是对应帖子的回复
        check = service.check_comment(postId, comment_id)
        if not check:
            return jsonify({'message': "not found"}), 404

        result = service.create_comment(content['content'], g.user_id, postId, comment_id)

        if result:
            return jsonify({'message': "ok"}), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400


# 暂时废除
# 删除指定回复
@bp.route('/deletecomment/<int:commentId>', methods=['POST'])
@login_required
def delete_comment(commentId):
    try:
        check = service.check_self_comment(commentId, g.user_id)
        if not check:
            return jsonify({'message': "not found"}), 404
        
        comment_list, flag = service.get_comment_list(commentId)
        if not flag: 
            return jsonify({'message': "not found"}), 404

        id_list = []
        for comment in comment_list:
            id_list.append(comment['id'])
        
        for id in id_list:
            flag = service.delete_comment(id)
            if not flag:
                return jsonify({'message': "delete error"}), 400

        result = service.delete_comment(commentId)

        if result:
            return jsonify({'message': "ok"}), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400


# 获取回复
@bp.route('/getcomment/<int:commentId>', methods=['GET'])
@login_required
def get_comment(commentId):
    try:
        if commentId == 0:
            return jsonify({'message': "not a comment"}), 400
        comment, flag = service.get_comment(commentId)

        if flag:
            return jsonify({
                'message': "ok",
                'id': comment.id,
                "userId": comment.user_id,
                "commentId": comment.comment_id,
                "postId": comment.post_id,
                "content": comment.content,
                "created": comment.created
            }), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400


# 获取回复列表
@bp.route('/getcommentlist', methods=['GET'])
@login_required
def get_comment_list():
    try:
        comment_id = request.args['comment_id']
        if comment_id == 0:
            return jsonify({'message': "not a comment"}), 400
        comment_list, flag = service.get_comment_list(comment_id)

        if flag:
            return jsonify({
                'message': "ok",
                'commentList': comment_list
            }), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400


# 修改回复
@bp.route('/modify/<int:postId>/comment/<int:commentId>', methods=['POST'])
@login_required
def modify_comment(postId, commentId):
    try:
        content = request.get_json()
        if content is None:
            return jsonify({'message': "no content"}), 400

        key, passed = comment_params_check(content)
        if not passed:
            return jsonify({'message': "invalid arguments: " + key}), 400

        # 检验回复是否是当前用户的回复
        check = service.check_self_comment(commentId, g.user_id)
        if not check:
            return jsonify({'message': "not found"}), 404

        result = service.update_comment(
            content['content'], g.user_id, postId, commentId)

        if result:
            return jsonify({'message': "ok"}), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400


# 点赞帖子
@bp.route('/supportpost/<int:postId>', methods=['POST'])
@login_required
def support_post(postId):
    try:
        content = request.get_json()
        if content is None:
            return jsonify({'message': "no content"}), 400

        if 'type' in content:
            if content['type'] != 1 and content['type'] != -1:
                return jsonify({'message': "error type input"}), 400
        else:
            return jsonify({'message': "no type"}), 400

        msg, result = service.support_post(postId, content['type'])

        if result:
            return jsonify({'message': msg}), 200
        else:
            return jsonify({'message': msg}), 500
    except:
        return jsonify({'message': "exception!"}), 400

# 搜索帖子
@bp.route('/searchpost', methods=['GET'])
@login_required
def search_post(postId):
    try:
        content = request.get_json()
        if content is None:
            return jsonify({'message': "no content"}), 400  

        raw_string = content['keywords']
        keywords = raw_string.split()

        result, flag = service.search_post(keywords)

        if flag:
            return jsonify({
                'message': "ok",
                'postList': result
            }), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400
