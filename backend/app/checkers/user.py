#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib
import re

def register_params_check(content):
    """
    username
    password
    nickname
    mobile
    address
    signature
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
        
    # mobile
    if 'mobile' in content:
        mobile = content['mobile']
        src = r'^[1-9][0-9]{10}$'
        if not re.match(src, mobile):
            return "mobile", False
    else:
        # mobile 缺失
        return "mobile", False
    
    # address
    if 'address' in content:
        address = content['address']
        src = r'^\w+@(qq|163|126|56|mail|gmail)\.com$'
        if not re.match(src, address):
            return "address", False
    else:
        # address 缺失
        return "address", False

    # signature
    if 'signature' in content:
        pass
    else:
        content['signature'] = "这个人很懒，没有留下任何信息。"

    return "ok", True


def change_params_check(content):
    """
    username
    password
    nickname
    mobile
    address
    signature
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
        
    # mobile
    if 'mobile' in content:
        mobile = content['mobile']
        src = r'^[1-9][0-9]{10}$'
        if not re.match(src, mobile):
            return "mobile", False
    else:
        # mobile 缺失
        return "mobile", False
    
    # address
    if 'address' in content:
        address = content['address']
        src = r'^\w+@(qq|163|126|56|mail|gmail)\.com$'
        if not re.match(src, address):
            return "address", False
    else:
        # address 缺失
        return "address", False

    # signature
    if 'signature' in content:
        pass
    else:
        content['signature'] = "这个人很懒，没有留下任何信息。"

    return "ok", True
