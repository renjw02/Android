#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib
import datetime

from sqlalchemy import and_

from app.utils import encrypt_password
from app.models import User, Follow, Blacklist
from app.extension import db

class UserService():
    ''' 
    accept a dictionary
    content = {
        'username':
        'password':
        'nickname':
        'mobile':
        'address':
        'signature':
    }
    '''

    def create_user(self, username, password, nickname):
        try:
            now = datetime.datetime.now()
            pw = encrypt_password(str(password))
            # TODO avatar
            u = User(username=username, password=pw, nickname=nickname, profile="这位用户很懒，什么也没写", 
                     created=now, updated=now, status=0)
            db.session.add(u)
            db.session.commit()
            return u, True
        except Exception as e:
            print(e)
            return "error", False

    # return a tuple
    def get_user_by_id(self, user_id):
        try:
            u = User.query.filter(User.id == user_id).first()
            return u, True
        except Exception as e:
            print(e)
            return "errors", False

    # return a tuple
    def get_user_by_name_and_pass(self, username, password):
        try:
            pw = encrypt_password(str(password))
            u = User.query.filter(
                and_(User.username == username, User.password == pw)).first()
            # u = User.query.filter(User.password == pw).first()
            if u is None:
                return "not found", False
            return u, True
        except Exception as e:
            print(e)
            return "errors", False

    
    def change_attr(self, user_id, username, nickname, mobile, address, signature):
        try:
            now = datetime.datetime.now()
            db.session.query(User).filter(User.id == user_id).update({
                'username': username,
                'nickname': nickname,
                'mobile': mobile,
                'address': address,
                'signature': signature,
                'updated': now
            })
            u = User.query.filter(User.id == user_id).first()
            db.session.commit()
            return u, True
        except Exception as e:
            print(e)
            db.session.rollback()
            return '用户名已存在', False  


    def get_user(self, user_id):
        try:
            u = User.query.filter(User.id == user_id).first()
            return u, True
        except Exception as e:
            print(e)
            return "errors", False

    
    def reset_pw(self, username, mobile, password):
        try:
            pw = encrypt_password(password)
            db.session.query(User).filter(User.username == username).update({
                'password': pw
            })
            db.session.commit()
            u = User.query.filter(User.username == username).first()
            return u, True
        except Exception as e:
            print(e)
            db.session.rollback()
            return 'error', False 

    
    def login(self, user_id):
        try:
            db.session.query(User).filter(User.id == user_id).update({
                'status': 1
            })
            db.session.commit()
            return True
        except Exception as e:
            print(e)
            db.session.rollback()
            return False
        
    def logout(self, user_id):
        try:
            db.session.query(User).filter(User.id == user_id).update({
                'status': 0
            })
            db.session.commit()
            return True
        except Exception as e:
            print(e)
            db.session.rollback()
            return False
        
    def check_user(self, user_id, m_id):
        try:
            if user_id == m_id:
                return False
            u = User.query.filter(User.id == user_id).first()
            if u is None:
                return False
            else:
                return True
        except Exception as e:
            print(e)
            return False
    
    def check_follow(self, follow_id):
        try:
            f = Follow.query.filter(Follow.id == follow_id).first()
            if f is None:
                return False
            else:
                return True
        except Exception as e:
            print(e)
            return False
        
    def check_block(self, block_id):
        try:
            b = Blacklist.query.filter(Blacklist.id == block_id).first()
            if b is None:
                return False
            else:
                return True
        except Exception as e:
            print(e)
            return False
        
    def follow_user(self, user_id, m_id):
        try:
            f = Follow(user_id=m_id, follow_id=user_id)
            db.session.add(f)
            db.session.commit()
            return f, True
        except Exception as e:
            print(e)
            return "error", False
        
    def block_user(self, user_id, m_id):
        try:
            b = Blacklist(user_id=m_id, blocked_id=user_id)
            db.session.add(b)
            db.session.commit()
            return b, True
        except Exception as e:
            print(e)
            return "error", False

    def cancel_follow(self, follow_id):
        try:
            db.session.query(Follow).filter(Follow.id == follow_id).delete()
            db.session.commit()
            return True
        except Exception as e:
            print(e)
            db.session.rollback()
            return False
    
    def cancel_block(self, block_id):
        try:
            db.session.query(Blacklist).filter(Blacklist.id == block_id).delete()
            db.session.commit()
            return True
        except Exception as e:
            print(e)
            db.session.rollback()
            return False


    def get_followed_list(self, user_id):
        try:
            followed_sql = """
            select follow.followed_id as followedUserId, follow.id as followId, 
                user.nickname as nickname, user.profile as profile 
            from follow
            inner join user on follow.followed_id = user.id
            where follow.user_id = {user_id}
            """
            followed_result = db.session.execute(followed_sql.format(user_id=user_id))
            followed_list = [dict(zip(result.keys(), result)) for result in followed_result]
            return followed_list, True
        except Exception as e:
            print(e)
            return [], False
        
    def get_my_follower_list(self, user_id):
        try:
            follower_sql = """
            select follow.user_id as followerId, follow.id as followId, 
                user.nickname as nickname, user.profile as profile 
            from follow
            inner join user on follow.user_id = user.id
            where follow.followed_id = {user_id}
            """
            follower_result = db.session.execute(follower_sql.format(user_id=user_id))
            follower_list = [dict(zip(result.keys(), result)) for result in follower_result]
            return follower_list, True
        except Exception as e:
            print(e)
            return [], False
        
    def get_blocked_list(self, user_id):
        try:
            blocked_sql = """
            select blacklist.blocked_id as blockedUserId, blacklist.id as blockId, 
                user.nickname as nickname, user.profile as profile 
            from blacklist
            inner join user on blacklist.blocked_id = user.id
            where blacklist.user_id = {user_id}
            """
            blocked_result = db.session.execute(blocked_sql.format(user_id=user_id))
            blocked_list = [dict(zip(result.keys(), result)) for result in blocked_result]
            return blocked_list, True
        except Exception as e:
            print(e)
            return [], False