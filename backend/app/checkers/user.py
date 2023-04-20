#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib
import re

def register_params_check(content):
    """
    username
    password
    nickname
    """
    # username
    if 'username' in content:
        username = content['username']
        src = r'^[A-Za-z0-9*-_@]{5,15}$'
        if not re.match(src, username):
            return "username", False
    else:
        return "username", False

    # password
    if 'password' in content:
        password = content['password']
        src = r'^[A-Za-z0-9]{6,16}$'
        if not re.match(src, password):
            return "password", False
    else:
        return "password", False
    
    # nickname
    if 'nickname' in content:
        nickname = content['nickname']
        if len(nickname) < 1 or len(nickname) > 14:
            return "nickname", False
    else:
        return "nickname", False
    
    return "ok", True

def change_params_check(content):
    """
    username
    password
    nickname
    profile
    """
    # username
    if 'username' in content:
        username = content['username']
        src = r'^[A-Za-z0-9*-_@]{5,15}$'
        if not re.match(src, username):
            return "username", False
    else:
        return "username", False
    
    # nickname
    if 'nickname' in content:
        nickname = content['nickname']
        if len(nickname) < 1 or len(nickname) > 14:
            return "nickname", False
    else:
        return "nickname", False

    # profile
    if 'profile' in content:
        pass
    else:
        return "profile", False

    return "ok", True
