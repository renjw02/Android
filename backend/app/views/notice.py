#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib
import os

from flask import Blueprint, jsonify, request, g
from app.services import NoticeService
from .login_required import login_required
from app.checkers import notice_params_check

bp = Blueprint('notice', __name__, url_prefix='/api/notice')

service = NoticeService()

@bp.route('/')
def index():
    return jsonify({'message': "notice配置完成!"}), 200


# 废除
# 创建通知
@bp.route('/createnotice', methods=['POST'])
def createnotice():
    try:
        # print(request)
        # print(request.form)
        
        content = request.get_json()
        # 打印日志
        print(content)
        # 打印content的类型
        print(type(content))
        print("============")
        print(content['user_id'])
        print(content['type'])
        print(content['content'])
        
        if content is None:
            return jsonify({'message': "no content"}), 400
        key, passed = notice_params_check(content)
        if not passed:
            return jsonify({'message': "invalid arguments: " + key}), 400


        if content['type'] == 0:
            # 系统消息
            notice, flag = service.create_notice(content['user_id'], content['type'], content['content'])
        elif content['type'] >= 1:
            # 私信
            notice, flag = service.create_notice(content['user_id'], content['type'], content['content'],
                                             content['creator_id'])
        
        if flag:
            return jsonify({
                'message': "ok",
                'noticeType': notice.type,
                'noticeId': notice.id
            }), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400
    

# 删除通知
@bp.route('/removenotice/<int:noticeId>', methods=['POST'])
@login_required
def remove_notice(noticeId):
    try:
        if not service.check_notice(noticeId):
            return jsonify({'message': "cannot remove unread notice"}), 400

        flag = service.remove_notice(noticeId)
        if flag:
            return jsonify({
                'message': "ok",
            }), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400


# 获取用户通知列表
@bp.route('/getnoticelist/<int:userId>', methods=['GET'])
@login_required
def get_notice_list(userId):
    try:
        notice_list, flag = service.get_notice_list(userId)
        if flag:
            return jsonify({
                'message': "ok",
                'noticeList': notice_list,
                'totalNum': len(notice_list)
            }), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400
    

# 获取私信内容
@bp.route('/getnotice/<int:noticeId>', methods=['GET'])
@login_required
def get_notice(noticeId):
    try:
        result = service.check_notice_and_user(noticeId, g.user_id)
        if not result:
            return jsonify({'message': "noticeId not match userId"}), 400
        
        notice, flag = service.get_notice_detail(noticeId)
        print(notice)
        print(notice.id)
        print(notice.content)
        print(notice.type)
        print(notice.created)
        print(notice.creator_id)
        if flag:
            return jsonify({
                'message': "ok",
                'noticeId': notice.id,
                'content': notice.content,
                'type': notice.type,
                'created': notice.created,
                'creator': notice.creator_id,
                'postId': notice.post_id 
            }), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400
    

# 获取未读数量
@bp.route('/getunreadnum/<int:userId>', methods=['GET'])
@login_required
def get_unread_num(userId):
    try:
        num, flag = service.get_unread_num(userId)
        if flag:
            return jsonify({
                'message': "ok",
                'unreadNum': num
            }), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400