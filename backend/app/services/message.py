#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib
import datetime
from sqlalchemy import and_

from extension import db
from models import Message

class MessageService():
    
    def create_message(self, sender_id, receiver_id, content):
        try:
            now = datetime.datetime.now()
            m = Message(sender_id=sender_id, receiver_id=receiver_id, content=content, created=now)
            db.session.add(m)
            db.session.commit()
            return m, True
        except Exception as e:
            print(e)
            return "error", False
    
    def get_history_message(self, user1_id, user2_id):
        try:
            sql = """
            select * 
            from message
            where (sender_id = {user1_id} and receiver_id = {user2_id}) or (sender_id = {user2_id} and 
                receiver_id = {user1_id}) 
            order by created desc
            """
            sql_content = sql.format(user1_id=user1_id, user2_id=user2_id)

            content_result = db.session.execute(sql_content)

            message_list = [dict(zip(result.keys(), result)) for result in content_result]

            return message_list, True
        except Exception as e:
            print(e)
            return [], False
   