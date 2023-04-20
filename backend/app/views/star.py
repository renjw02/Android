#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib
import os

from flask import Blueprint, jsonify, request, g
from services import StarService
from utils import login_required

bp = Blueprint('user', __name__, url_prefix='/api/star')

service = StarService()

@bp.route('/')
def index():
    return jsonify({'message': "star配置完成!"}), 200


# 收藏帖子
@bp.route('/collectpost', methods=['POST'])
@login_required
def collect_post():
    try:
        content = request.get_json()
        if content is None:
            return jsonify({'message': "no content"}), 400

        collection, flag = service.collect_post(content['post_id'], content['user_id'], content['title'])
        if flag:
            return jsonify({
                'message': "ok",
                'collectionId': collection.id,
                'postId': collection.post_id,
                'userId': collection.user_id,
                'created': collection.created
            }), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400
    

# 取消收藏
@bp.route('/cancelcollection', methods=['POST'])
@login_required
def cancel_collection():
    try:
        content = request.get_json()
        if content is None:
            return jsonify({'message': "no content"}), 400
        result = service.check_collection(content['collection_id'])

        flag = service.cancel_collection(content['collection_id'], content['post_id'])
        if flag:
            return jsonify({
                'message': "ok",
            }), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400


# 获取用户收藏列表
@bp.route('/getcollectionlist/<int:userId>', methods=['GET'])
@login_required
def get_collection_list(userId):
    try:
        collection_list, flag = service.get_collection_list(userId)
        if flag:
            return jsonify({
                'message': "ok",
                'collectionList': collection_list,
                'totalNum': collection_list.length()
            }), 200
        else:
            return jsonify({'message': "error"}), 500
    except:
        return jsonify({'message': "exception!"}), 400