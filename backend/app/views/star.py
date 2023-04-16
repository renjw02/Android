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
        