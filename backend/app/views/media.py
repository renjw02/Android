#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib
import os, base64

from flask import Blueprint, jsonify, request, g, make_response
from app.services import UserService
from app.checkers import register_params_check, change_params_check
from app.utils import generate_jwt, remove_jwt
from .login_required import login_required
import sys

bp = Blueprint('media', __name__, url_prefix='/api/media')


@bp.route('/')
def index():
    return jsonify({'message': "media配置完成!"}), 200

# 获取照片
@bp.route('/photo', methods=['GET'])
@login_required
def get_photo():
    try:
        print(request,file=sys.stderr)
        print(request.args,file=sys.stderr)
        file_name = request.args['name']
        print(file_name,file=sys.stderr)
        if file_name is None:
            return jsonify({'message': "no file name"}), 400
        path = os.path.abspath(os.path.join(os.path.dirname(__file__), os.path.pardir, "static", "images", str(file_name)))
        print(path,file=sys.stderr)
        imageData = open(path, "rb").read()
        response = make_response(imageData)
        response.headers['Content-Type'] = 'image/jpeg'
        return response, 200
    except:
        return jsonify({'message': "exception!"}), 400  
    

# 获取视频
@bp.route('/video', methods=['GET'])
@login_required
def get_video():
    try:
        print(request,file=sys.stderr)
        print(request.args,file=sys.stderr)
        file_name = request.args['name']
        print(file_name,file=sys.stderr)
        if file_name is None:
            return jsonify({'message': "no file name"}), 400
        path = os.path.abspath(os.path.join(os.path.dirname(__file__), os.path.pardir, "static", "videos", str(file_name)))
        print(path,file=sys.stderr)
        videoData =base64.b64encode(open(path, "rb").read()).decode('utf-8') 
        response = make_response(videoData)
        response.headers['Content-Type'] = 'video/mp4'
        return response, 200
    except:
        return jsonify({'message': "exception!"}), 400  