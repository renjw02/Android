#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib
import datetime
from sqlalchemy import and_

from extension import db
from models import Notice

class NoticeService():
    
    def create_notice(self, user_id, type, content, creator_id=0):
        try:
            now = datetime.datetime.now()
            n = Notice(user_id=user_id, type=type, content=content, creato_id=creator_id, 
                       created=now, has_checked=False)
            db.session.add(n)
            db.session.commit()
            return n, True
        except Exception as e:
            print(e)
            return "error", False
        
    def remove_notice(self, notice_id):
        try:
            db.session.query(Notice).filter(Notice.id == notice_id).delete()
            db.session.commit()
            return True
        except Exception as e:
            print(e)
            db.session.rollback()
            return False
    
    def get_unread_num(self, user_id):
        try:
            sql = """
            select count(id) as count
            from notice
            where user_id = {user_id} and has_checked = False
            """
            sql_count = sql.format(user_id=user_id)
            count_result = db.session.execute(sql_count)
            count = [dict(zip(result.keys(), result)) for result in count_result]

            return count[0]['count'], True
        except Exception as e:
            print(e)
            return None, False

    def get_notice_list(self, user_id):
        try:
            sql = """
            select id as noticeId, user_id as userId, type as noticeType, creator as noticeCreator,
                created as noticeCreated, has_checked as hasChecked
            from notice
            where user_id = {user_id}
            order by created desc
            """
            sql_content = sql.format(user_id=user_id)

            content_result = db.session.execute(sql_content)

            notice_list = [dict(zip(result.keys(), result)) for result in content_result]

            return notice_list, True
        except Exception as e:
            print(e)
            return [], False

    def get_notice_detail(self, notice_id):
        try:
            n = Notice.query.filter(Notice.id == notice_id).first()
            n.has_checked = True
            db.session.commit()
            if n is None:
                return None, False
            return n, True
        except Exception as e:
            print(e)
            db.session.rollback()
            return None, False

    def check_notice_and_user(self, notice_id, user_id):
        try:
            n = Notice.query.filter(Notice.id == notice_id).first()
            if n is None:
                return False
            if n.user_id == user_id:
                return True
            return False
        except Exception as e:
            print(e)
            return False
        
    def check_notice(self, notice_id):
        try:
            n = Notice.query.filter(Notice.id == notice_id).first()
            if n is None:
                return False
            if n.has_checked == False:
                return False
            return True
        except Exception as e:
            print(e)
            return False