#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import libapp.
import datetime
from sqlalchemy import and_, text

from app.extension import db
from app.models import Star, Post

class StarService():
    def collect_post(self, post_id, user_id, title):
        try:
            now = datetime.datetime.now()
            tmp = Star.query.filter(and_(Star.user_id == user_id, Star.post_id == post_id)).first()
            if tmp is not None:
                return "already exist", False
            
            s = Star(post_id=post_id, user_id=user_id, title=title, created=now)
            db.session.add(s)
            db.session.query(Post).filter(Post.id == post_id).update({
                "starNum": Post.star_num + 1
            })
            db.session.commit()
            return s, True
        except Exception as e:
            print(e)
            return "error", False
        
    def cancel_collection(self, star_id, post_id):
        try:
            db.session.query(Star).filter(Star.id == star_id).delete()
            db.session.query(Post).filter(Post.id == post_id).update({
                "starNum": Post.star_num - 1
            })
            db.session.commit()
            return True
        except Exception as e:
            print(e)
            db.session.rollback()
            return False
        
    def get_collection_list(self, user_id):
        try:
            collect_sql = """
            select id as starId, post_id as postId, title as postTitle, created as created
            from star
            where user_id = {user_id}
            order by created desc
            """
            collection_result = db.session.execute(text(collect_sql.format(user_id=user_id)))
            collection_list = [dict(zip(result.keys(), result)) for result in collection_result]

            return collection_list, True
        except Exception as e:
            print(e)
            return [], False

    def check_collection_and_post(self, star_id):
        try:
            s = Star.query.filter(Star.id == star_id).first()
            if s.post_id is None:
                return True
            else:
                return False
        except Exception as e:
            print(e)
            return False
        
    def check_collection(self, star_id):
        try:
            s = Star.query.filter(Star.id == star_id).first()
            if s is None:
                return False
            else:
                return True
        except Exception as e:
            print(e)
            return False

