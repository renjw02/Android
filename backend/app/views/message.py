#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib
import os

from flask import Blueprint, jsonify, request, g
from services import MessageService
from utils import login_required

bp = Blueprint('user', __name__, url_prefix='/api/message')

service = MessageService()

@bp.route('/')
def index():
    return jsonify({'message': "message配置完成!"}), 200


# 创建私信
@bp.route('/createmessage', methods=['POST'])
@login_required
def create_message():
    try:
        content = request.get_json()
        if content is None:
            return jsonify({'message': "no content"}), 400
        # TODO check_content
        message, flag = service.create_message(content['sender_id'], content['receiver_id'], 
                                               content['content'])
        if flag:
            return jsonify({
                'message': "ok",
                'messageId': message.id,
                'content': message.content,
                'sendTime': message.created
            }), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400
    

# 删除私信
@bp.route('/removemessage', methods=['POST'])
@login_required
def remove_message():
    pass

# 获取历史对话
@bp.route('/gethistory/<int:user1Id>/<int:user2Id>', methods=['GET'])
@login_required
def get_history(user1Id, user2Id):
    try:
        message_list, flag = service.get_history_message(user1Id, user2Id)
        if flag:
            return jsonify({
                'message': "ok",
                'history': message_list,
                'totalNum': message_list.length()
            }), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400