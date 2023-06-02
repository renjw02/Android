#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib
import os

from flask import Blueprint, jsonify, request, g
from app.services import MessageService, NoticeService, UserService
from .login_required import login_required
from app.checkers import message_params_check

bp = Blueprint('message', __name__, url_prefix='/api/message')

service = MessageService()
notice_service = NoticeService()
user_service = UserService()

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
        key, passed = message_params_check(content)
        if not passed:
            return jsonify({'message': "invalid arguments: " + key}), 400

        message, flag = service.create_message(content['sender_id'], content['receiver_id'], 
                                               content['content'])
        if flag:
            # 创建通知
            receiver, flag_fake = user_service.get_user(content['receiver_id'])
            sender, flag_fake = user_service.get_user(content['sender_id'])
            print("===============")
            print(receiver)
            print(sender)
            print(message)
            info = "用户" + sender.nickname + "给您发送了一条新的消息"             
            print(info)
            notice, flag1 = notice_service.create_notice(receiver.id, 0, info, sender.id)
            print("===============")
            print(notice)
            if not flag1:
                return jsonify({'message': "failed to create notice"}), 500

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
        # print(message_list)
        length = len(message_list)
        # print(flag)
        if flag:
            return jsonify({
                'message': "ok",
                'history': message_list,
                'totalNum': length,
            }), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400