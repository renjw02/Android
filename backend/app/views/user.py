#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib
import os

from flask import Blueprint, jsonify, request, g, make_response
from app.services import UserService
from app.checkers import register_params_check, change_params_check
from app.utils import generate_jwt, remove_jwt
from .login_required import login_required
import sys

bp = Blueprint('user', __name__, url_prefix='/api/user')

service = UserService()

@bp.route('/')
def index():
    return jsonify({'message': "user配置完成!"}), 200

@bp.route('/register', methods=['POST'])
def user_register():
    """
    注册
    """
    try:
        content = request.get_json()
        if not content:
            return jsonify({'message': "no content"}), 400
        key, passed = register_params_check(content)
        if not passed:
            return jsonify({'message': "invalid arguments: " + key}), 400

        user, flag = service.create_user(content['username'],
                                   content['password'],
                                   content['nickname'])

        if flag:
            return jsonify({
                'message': "ok",
                'userId' : user.id,
                'username': user.username,
                'nickname': user.nickname
            }), 200
        else:
            return jsonify({'message': "database error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400


@bp.route('/login', methods=['POST'])
def login():
    """
    登陆
    """
    try:
        
        content = request.get_json()
        if not content:
            return jsonify({'message': "no content"}), 400

        user, flag = service.get_user_by_name_and_pass(content['username'], content['password'])
        if user.status == 1:
            return jsonify({'message': "user has already logged in"}), 300
        
        if flag:
            service.login(user.id)

            jwt = generate_jwt({
                "user_id": user.id,
                "nickname": user.nickname
            })

            return jsonify({
                "message": 'ok',
                "jwt": jwt,
                "userId": user.id,
                "username": user.username,
                "nickname": user.nickname,
                "profile": user.profile
            }), 200
        else:
            return jsonify({'message': user}), 500
    except:
        return jsonify({'message': "exception!"}), 400


@bp.route('/logout', methods=['POST'])
@login_required
def logout():
    """
    登出
    """
    try:
        flag = service.logout(g.user_id)
        remove_jwt(g.user_id)
        if flag:
            return jsonify({'message': "ok"}), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400


# id传整数
@bp.route('/changeattr', methods=['POST'])
@login_required
def change_attr():
    """
    改变属性
    """
    try:
        content = request.get_json()
        if not content:
            return jsonify({'message': "no content"}), 400
        # print(content)

        key, passed = change_params_check(content)
        if not passed:
            return jsonify({'message': "invalid arguments: " + key}), 400
        
        user, flag = service.change_attr(g.user_id, content['username'],
                                content['nickname'], content['profile'])
        print(123)
        if flag:
            return jsonify({
                'message': "ok",
                'username': user.username,
                'nickname': user.nickname,
                'profile': user.profile
                }), 200
        else:
            return jsonify({'message': user}), 500
    except:
        return jsonify({'message': "exception!"}), 400    


@bp.route('/user', methods=['GET'])
@login_required
def get_user_info():
    """
    获取当前登录用户信息
    """
    user, flag = service.get_user(g.user_id)
    if flag:
        return jsonify({
            "id":       user.id,
            "username": user.username,
            "nickname": user.nickname,
            "created":  user.created,
            "profile": user.profile 
        }), 200
    else:
        return jsonify({'message': user}), 500


@bp.route('/user/<int:userId>', methods=['GET'])
@login_required
def get_user_info_by_id(userId):
    """
    获取指定用户信息
    """
    user, flag = service.get_user(userId)
    if flag:
        return jsonify({
            "id":       user.id,
            "username": user.username,
            "nickname": user.nickname,
            "created":  user.created,
            "profile": user.profile,
        }), 200
    else:
        return jsonify({'message': user}), 500



@bp.route('/resetpw', methods=['POST'])
def reset_password():
    """
    修改密码
    """
    try:
        content = request.get_json()
        if not content:
            return jsonify({'message': "no content"}), 400

        if 'username' not in content or "password" not in content:
            return jsonify({'message': "lack parameters"}), 400
        
        user, flag = service.reset_pw(content['username'], content['password'])
        if flag:
            return jsonify({
                'message': "ok",
                'userId': user.id
                }), 200
        else:
            return jsonify({'message': user}), 500
    except:
        return jsonify({'message': "exception!"}), 400    


# 上传头像
@bp.route('/uploadavatar', methods=['POST'])
@login_required
def upload_avatar():
    try:
        print(request,file=sys.stderr)
        print(request.data,file=sys.stderr)
        print(request.files,file=sys.stderr)
        print(request.headers,file=sys.stderr)
        print(request.form,file=sys.stderr)
        print(request.input_stream,file=sys.stderr)
        file_obj = request.files.get('file')
        print("success",file=sys.stderr)
        file_name = file_obj.filename
        print(file_name)
        print("success",file=sys.stderr)
        save_path = os.path.abspath(os.path.join(os.path.dirname(__file__), os.path.pardir, "static", "avatar", str(file_name)))
        print(save_path)
        file_obj.save(save_path)
        print("success",file=sys.stderr)
        workpath = os.getcwd()
        dst = os.path.join(workpath, 'app', 'static', 'avatar', str(g.user_id)+'.jpg')
        if os.path.exists(dst):
            os.remove(dst)
        os.rename(save_path, dst)
        print("success",file=sys.stderr)
        return jsonify({'message': "ok"}), 200
    except:
        return jsonify({'message': "exception!"}), 400  


# 获取头像
@bp.route('/downloadavatar', methods=['GET'])
@login_required
def download_avatar():
    try:
        print(request,file=sys.stderr)
        print(request.args,file=sys.stderr)
        file_name = request.args['name']
        print(file_name,file=sys.stderr)
        if file_name is None:
             return jsonify({'message': "no file name"}), 400
        path = os.path.abspath(os.path.join(os.path.dirname(__file__), os.path.pardir, "static", "avatar", str(file_name)))
        print(path,file=sys.stderr)
        imageData = open(path, "rb").read()
        response = make_response(imageData)
        response.headers['Content-Type'] = 'image/jpeg'
        return response, 200
    except:
        return jsonify({'message': "exception!"}), 400  
    

# 关注用户
@bp.route('/followuser/<int:userId>',methods=['POST'])
@login_required
def follow_user(userId):
    try:
        result = service.check_user(userId, g.user_id)
        if not result:
            return jsonify({'message': "not found user " + str(userId)}), 400
        
        follow, flag = service.follow_user(userId, g.user_id)
        if flag:
            return jsonify({
                'message': "ok",
                'followed_id': follow.followed_id                       
                }), 200
        else:
            return jsonify({'message': follow}), 500
    except:
        return jsonify({'message': "exception!"}), 400  
    

# 取消关注
@bp.route('/cancelfollow/<int:followId>',methods=['POST'])
@login_required
def cancel_follow(followId):
    try:
        result = service.check_follow(followId)
        if not result:
            return jsonify({'message': "not found item " + str(followId)}), 400
        
        flag = service.cancel_follow(followId)
        if flag:
            return jsonify({'message': "ok"}), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400  
    

# 获取已关注用户列表
@bp.route('/getfollowedlist/<int:userId>', methods=['GET'])
@login_required
def get_followed_list(userId):
    try:
        followed_list, flag = service.get_followed_list(userId)
        print(followed_list)
        if flag:
            return jsonify({
                'message': "ok",
                'followedList': followed_list,
                'totalNum': len(followed_list)
            }), 200
        else: return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400 
    

# 获取关注我的用户列表
@bp.route('/getfollowerlist/<int:userId>', methods=['GET'])
@login_required
def get_follower_list(userId):
    try:
        follower_list, flag = service.get_my_follower_list(userId)
        if flag:
            return jsonify({
                'message': "ok",
                'followerList': follower_list,
                'totalNum': len(follower_list)
            }), 200
        else: return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400 


# 拉黑用户
@bp.route('/blockuser/<int:userId>',methods=['POST'])
@login_required
def block_user(userId):
    try:
        result = service.check_user(userId, g.user_id)
        if not result:
            return jsonify({'message': "not found user " + str(userId)}), 400
        
        block, flag = service.block_user(userId, g.user_id)
        if flag:
            return jsonify({
                'message': "ok",
                'blocked': block                      
                }), 200
        else:
            return jsonify({'message': block}), 500
    except:
        return jsonify({'message': "exception!"}), 400  
    

# 取消拉黑
@bp.route('/cancelblock/<int:blockId>',methods=['POST'])
@login_required
def cancel_block(blockId):
    try:
        result = service.check_block(blockId)
        if not result:
            return jsonify({'message': "not found item " + str(blockId)}), 400
        
        flag = service.cancel_block(blockId)
        if flag:
            return jsonify({'message': "ok"}), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400 
    

# 获取已拉黑用户列表
@bp.route('/getblockedlist/<int:userId>', methods=['GET'])
@login_required
def get_blocked_list(userId):
    try:
        blocked_list, flag = service.get_blocked_list(userId)
        if flag:
            return jsonify({
                'message': "ok",
                'blockedList': blocked_list,
                'totalNum': len(blocked_list)
            }), 200
        else: return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400 