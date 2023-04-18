#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib
import os

from flask import Blueprint, jsonify, request, g
from services import NoticeService
from utils import login_required

bp = Blueprint('user', __name__, url_prefix='/api/notice')

service = NoticeService()

@bp.route('/')
def index():
    return jsonify({'message': "notice配置完成!"}), 200


# 创建通知
@bp.route('/createnotice', methods=['POST'])
def createnotice():
    try:
        content = request.get_json()
        if content is None:
            return jsonify({'message': "no content"}), 400
        # TODO check_content
        if content['type'] == 0:
            # 系统消息
            notice, flag = service.create_notice(content['user_id'], content['type'], content['content'])
        elif content['type'] == 1:
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
@bp.route('/removenotice', methods=['POST'])
@login_required
def remove_notice():
    try:
        content = request.get_json()
        if content is None:
            return jsonify({'message': "no content"}), 400
        
        # TODO check content
        
        if not service.check_notice(content['notice_id']):
            return jsonify({'message': "cannot remove unread notice"}), 400

        flag = service.remove_notice(content['notice_id'])
        if flag:
            return jsonify({
                'message': "ok",
            }), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400


# 获取用户私信列表
@bp.route('/getnoticelist/<int:userId>', methods=['GET'])
@login_required
def get_notice_list(userId):
    try:
        notice_list, flag = service.get_notice_list(userId)
        if flag:
            return jsonify({
                'message': "ok",
                'collectionList': notice_list,
                'totalNum': notice_list.length()
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
        if flag:
            return jsonify({
                'message': "ok",
                'noticeId': notice.id,
                'content': notice.content,
                'type': notice.type,
                'created': notice.created,
                'creator': notice.creator 
            }), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400
    

# 获取未读数量
@bp.route('/getunreadnum/<int:userId>', methods=['GET'])
@login_required
def get_notice(userId):
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