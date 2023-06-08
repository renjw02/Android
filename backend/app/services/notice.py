#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib
import datetime
from sqlalchemy import and_, text

from app.extension import db
from app.models import Notice

class NoticeService():
    
    def create_notice(self, user_id, type, content, creator_id=0, post_id=0):
        try:
            notice = Notice.query.filter(and_(Notice.user_id==user_id, 
                                              Notice.creator_id==creator_id)).first()

            now = datetime.datetime.now()
            if notice is None:
                n = Notice(user_id=user_id, type=type, content=content, creator_id=creator_id, 
                            created=now, has_checked=False, post_id=post_id)
                db.session.add(n)
                db.session.commit()
                return n, True
            else:
                db.session.query(Notice).filter(Notice.id == notice.id).update({
                'created': now
                })
                db.session.commit()
                return "update old one", True
        except Exception as e:
            print(e)
            db.session.rollback()
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
            count_result = db.session.execute(text(sql_count))
            count = [dict(zip(result.keys(), result)) for result in count_result]

            return count[0]['count'], True
        except Exception as e:
            print(e)
            return None, False

    def get_notice_list(self, user_id):
        try:
            sql = """
            select id as noticeId, user_id as userId, type as noticeType, creator_id as noticeCreator,
                created as created, has_checked as hasChecked
            from notice
            where user_id = {user_id}
            order by created desc
            """
            # sql_content = sql.format(user_id=user_id)

            content_result = db.session.execute(text(sql.format(user_id=user_id)))
            column_names = content_result.keys()
            notice_list = []
            
            for row in content_result:
                notice_dict = dict(zip(column_names, row))
                notice_list.append(notice_dict)
            # notice_list = [dict(zip(result.keys(), result)) for result in content_result]
            
            return notice_list, True
        except Exception as e:
            print("sql error")
            print(e)
            return [], False

    def get_notice_detail(self, notice_id):
        try:
            n = Notice.query.filter(Notice.id == notice_id).first()
            print(n)
            n.has_checked = True
            db.session.commit()
            print(n)
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