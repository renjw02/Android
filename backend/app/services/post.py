#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib
import datetime
from sqlalchemy import and_, or_, text

from app.extension import db
from app.models import Post, Comment, User, Picture, Video, Support
import sys

class PostService():
    
    def create_post(self, title, content, user_id, type, position,
                    font_size, font_color, font_weight):
        try:
            now = datetime.datetime.now()
            p = Post(user_id=user_id, title=title, content=content, type=type, position=position,
                    last_replied_user_id=user_id, support_num=0, comment_num=0, star_num=0,
                    last_replied_time=now, created=now, updated=now, font_size=font_size,
                    font_color=font_color, font_weight=font_weight)
            db.session.add(p)
            db.session.commit()
            return p, True
        except Exception as e:
            print(e)
            return "error", False

    def update_post(self, title, content, post_id, position, font_size, font_color, font_weight):
        try:
            now = datetime.datetime.now()
            db.session.query(Post).filter(Post.id == post_id).update({
                "title": title,
                "content": content,
                "position": position,
                "updated": now,
                "font_size": int(font_size),
                "font_color": font_color,
                "font_weight": font_weight
            })
            db.session.commit()
            return True
        except Exception as e:
            print(e)
            db.session.rollback()
            return False

    def delete_post(self, post_id):
        try:
            db.session.query(Post).filter(Post.id == post_id).delete()
            db.session.commit()
            return True
        except Exception as e:
            print(e)
            db.session.rollback()
            return False

    # 回复的是一个帖子，则不传入Comment_id
    # Comment_id: 将要回复的是一个Comment，其id为Comment_id
    def create_comment(self, content, user_id, post_id, comment_id=0):
        try:
            now = datetime.datetime.now()
            r = Comment(user_id=user_id, content=content, post_id=post_id,
                    comment_id=comment_id, created=now, updated=now)
            db.session.add(r)
            db.session.query(Post).filter(Post.id == post_id).update({
                "last_replied_time": now,
                "last_replied_user_id": user_id,
                "comment_num": Post.comment_num + 1
            })
            db.session.commit()
            return r, True
        except Exception as e:
            db.session.rollback()
            print(e)
            return "error", False

    def update_comment(self, content, user_id, post_id, comment_id):
        try:
            now = datetime.datetime.now()
            db.session.query(Comment).filter(and_(Comment.id == comment_id, Comment.user_id == user_id)).update({
                "content": content,
                "updated": now
            })
            db.session.query(Post).filter(Post.id == post_id).update({
                "last_replied_time": now,
                "last_replied_user_id": user_id,
            })
            db.session.commit()
            return True
        except Exception as e:
            # 失败了之后事务回滚
            db.session.rollback()
            print(e)
            return False

    def delete_comment(self, comment_id):
        try:
            db.session.query(Comment).filter(Comment.id == comment_id).delete()
            db.session.query(Post).filter(Post.id == Comment.post_id).update({
                "comment_num": Post.comment_num - 1
            })
            db.session.commit()
            return True
        except Exception as e:
            print(e)
            db.session.rollback()
            return False


    # 默认按帖子更新时间排序
    def get_post_list(self, user_id=0, page=1, size=10, order_by_what=None, typei=0, 
                      only_following=False, hot=False):
        try:  
            # print(order_by_what, typei, only_following, hot)
            # order_by_what := ["post.support_num", "post.comment_num"]
            if order_by_what is None:
                order_col = "post.created"
            else:
                order_col = order_by_what

            where_clause = ""
            if int(user_id) != 0:
                where_clause = "where post.user_id = " + str(user_id)
            
            if typei != 0:
                where_clause = "where post.type = " + str(typei)

            if only_following:
                where_clause = '''
                    where post.user_id in (
                        select followed_id
                        from follow
                        where follow.user_id = post.user_id
                        )
                        '''
            if hot:
                where_clause = "where post.support_num > 10 and post.comment_num > 5"

            content_base = '''
                select
                    post.id as id, post.user_id as userId, create_user.nickname as nickname,
                    post.title as title, post.content as content, post.support_num as supportNum,
                    post.star_num as starNum, post.comment_num as commentNum, post.type as type,
                    post.last_replied_user_id as lastRepliedUserId, 
                    comment_user.nickname as lastRepliedNickname,
                    post.last_replied_time as lastRepliedTime, 
                    post.created as created, post.updated as updated,
                    post.font_size as fontSize, post.font_color as fontColor, 
                    post.font_weight as fontWeight
                from
                    post
                inner join user as create_user on post.user_id = create_user.id
                inner join user as comment_user on post.last_replied_user_id = comment_user.id
                {where}
                order by {order} desc
                limit {limit}
                offset {offset};
            '''
            count_base = '''
                select
                    count(post.id) as count
                from
                    post
                {where}
            '''
            
            sql_content = content_base.format(limit=size, offset=(
                page-1)*size, order=order_col, where=where_clause)
            # print(sql_content)
            sql_count = count_base.format(where=where_clause)


            content_result = db.session.execute(text(sql_content))
            column_names = content_result.keys()
            post_list = []

            for row in content_result.fetchall():
                post_dict = dict(zip(column_names, row))
                post_list.append(post_dict)

            count_result = db.session.execute(text(sql_count))
            column_names = count_result.keys()
            count = []
            for row in count_result.fetchall():
                post_dict = dict(zip(column_names, row))
                count.append(post_dict)

            return post_list, count[0]['count'], True
        except Exception as e:
            print("asd")
            print(e)
            return [], 0, False
    
    def check_post(self, post_id, user_id):
        try:
            p = Post.query.filter(Post.id == post_id).first()
            if p.user_id == int(user_id):
                return True
            else:
                return False
        except Exception as e:
            print(e)
            return False

    def check_comment(self, post_id, comment_id):
        try:
            if comment_id == 0:
                p = Post.query.filter(Post.id == post_id).first()
                if p is None:
                    return False
                else:
                    return True
            else:
                r = Comment.query.filter(Comment.id == comment_id).first()
                if r.post_id == int(post_id):
                    return True
                else:
                    return False
        except Exception as e:
            print(e)
            return False

    def check_self_comment(self, comment_id, user_id):
        try:
            r = Comment.query.filter(Comment.id == comment_id).first()
            if r.user_id == int(user_id):
                return True
            else:
                return False
        except Exception as e:
            print(e)
            return False

    def get_post_detail(self, post_id):
        try:
            post_sql = '''
                select
                    post.id as id, post.user_id as userId, user.nickname as nickname,
                    post.title as title, post.content as content, post.support_num as supportNum,
                    post.star_num as starNum, post.comment_num as commentNum,
                    post.created as created, post.updated as updated, 
                    post.last_replied_time as lastRepliedTime, post.font_size as fontSize,
                    post.font_color as fontColor, post.font_weight as fontWeight
                from
                    post
                inner join user on post.user_id = user.id
                where
                    post.id = {post_id};
            '''
            comment_sql = '''
                select
                    comment.id as id, comment.user_id as userId, user.nickname as nickname,
                    comment.post_id as postId, comment.comment_id as commentId,
                    comment.content as content, comment.created as created, comment.updated as updated
                from
                    comment
                inner join user on comment.user_id = user.id
                where
                    comment.post_id = {post_id}
                order by comment.created asc;
            '''
            
            print("asd")
            post_result = db.session.execute(text(post_sql.format(post_id=post_id)))
            column_names = post_result.keys()
            print("asd")
            post = {}
            for row in post_result.fetchall():
                post_dict = dict(zip(column_names, row))
                post = post_dict
            print("asd")
            comment_result = db.session.execute(text(comment_sql.format(post_id=post_id)))
            column_names = comment_result.keys()
            comment_list = []
            print("asd")
            for row in comment_result.fetchall():
                comment_dict = dict(zip(column_names, row))
                comment_list.append(comment_dict)
            print("asd")
            # post = [dict(zip(result.keys(), result))
            #         for result in post_result][0]
            # comment_list = [dict(zip(result.keys(), result))
            #               for result in comment_result]

            # Comment列表包括帖子底下所有的回复，包括对帖子和对回复的
            post['comments'] = comment_list
            '''
            post = {
                'id':
                'userId":
                'nickname':
                'title':
                'content':
                'created':
                'updated':
                'lastRepliedTime':
                'comments':
            }
            '''
            print(post['title'])
            return post, True
        except Exception as e:
            print(e)
            return None, False


    def get_comment(self, comment_id):
        try:
            r = Comment.query.filter(Comment.id == comment_id).first()
            return r, True
        except Exception as e:
            print(e)
            return 'errors', False

    def get_comment_list(self, comment_id):
        try:
            comment_sql = '''
                select
                    comment.id as id, comment.user_id as userId, user.nickname as nickname,
                    comment.post_id as postId, comment.comment_id as commentId,
                    comment.content as content, comment.favor_num as favor_num, 
                    comment.created as created, comment.updated as updated
                from
                    comment
                inner join user on comment.user_id = user.id
                where
                    comment.comment_id = {comment_id}
                order by comment.created asc;
            '''
            comment_result = db.session.execute(text(comment_sql.format(comment_id=comment_id)))
            comment_list = [dict(zip(result.keys(), result)) for result in comment_result]
            return comment_list, True
        except Exception as e:
            print(e)

            return [], False


    def support_post(self, user_id, post_id):
        try:
            now = datetime.datetime.now()
            tmp = Support.query.filter(and_(Support.user_id == user_id, Support.post_id == post_id)).first()
            if tmp is not None:
                return "already exist", False
            
            s = Support(post_id=post_id, user_id=user_id, created=now)
            db.session.add(s)
            db.session.query(Post).filter(Post.id == post_id).update({
                "support_num": Post.favor_num+1,
                "updated": now
            })
            db.session.commit()
            return 'ok', True
        except Exception as e:
            print(e)
            db.session.rollback()
            return 'errors', False
        
    def cancel_support_post(self, user_id, post_id):
        try:
            db.session.query(Support).filter(and_(Support.user_id == user_id, Support.post_id == post_id)).delete()
            db.session.query(Post).filter(Post.id == post_id).update({
                "support_num": Post.favor_num-1
            })
            db.session.commit()
            return 'ok', True
        except Exception as e:
            print(e)
            db.session.rollback()
            return 'errors', False

    def search_post(self, args):   
        try:
            title_conditions = [Post.title.like(f'%{arg}%') for arg in args]
            content_conditions = [Post.content.like(f'%{arg}%') for arg in args]
            nickname_conditions = [User.nickname.like(f'%{arg}%') for arg in args]
            query = db.session.query(Post).join(User)
            conditions = or_(*title_conditions, *content_conditions, *nickname_conditions)
            result = query.filter(conditions).all()

            return result, True
        except Exception as e:
            print(e)
            return 'errors', False
    
    def upload_picture(self, post_id, path):
        try:
            p = Picture(post_id=post_id, path=path)
            db.session.add(p)
            db.session.commit()
            return p, True
        except Exception as e:
            print(e)
            return "error", False

    def upload_video(self, post_id, path):
        try:
            v = Video(post_id=post_id, path=path)
            db.session.add(v)
            db.session.commit()
            return v, True
        except Exception as e:
            print(e)
            return "error", False
        
    def get_pictures(self, post_id):
        try:
            sql = """
            select *
            from picture
            where post_id = {post_id}
            """
            results = db.session.execute(text(sql.format(post_id=post_id)))
            column_names = results.keys()
            pictures = []
            print("asd")
            for row in results.fetchall():
                picture_dict = dict(zip(column_names, row))
                pictures.append(picture_dict)
            # pictures = [dict(zip(result.keys(), result)) for result in results]
            return pictures, True
        except Exception as e:
            print(e)
            return [], False
        
    def get_videos(self, post_id):
        try:
            sql = """
            select *
            from video
            where post_id = {post_id}
            """
            results = db.session.execute(text(sql.format(post_id=post_id)))
            column_names = results.keys()
            videos = []
            print("asd")
            for row in results.fetchall():
                video_dict = dict(zip(column_names, row))
                videos.append(video_dict)
            # videos = [dict(zip(result.keys(), result)) for result in results]
            return videos, True
        except Exception as e:
            print(e)
            return [], False
        
    def get_star_list(self, post_id):
        try:
            print("star")
            sql = """
            select user_id
            from star
            where post_id = {post_id}
            """

            results = db.session.execute(text(sql.format(post_id=post_id)))
            column_names = results.keys()
            star_list = []

            for row in results.fetchall():
                star_dict = dict(zip(column_names, row))
                star_list.append(star_dict)
            return star_list, True
        except Exception as e:
            print("star exception",file=sys.stderr)
            print(e)
            return [], False
    
    def get_support_list(self, post_id):
        try:
            sql = """
            select user_id
            from support
            where post_id = {post_id}
            """
            results = db.session.execute(text(sql.format(post_id=post_id)))
            column_names = results.keys()
            support_list = []

            for row in results.fetchall():
                support_dict = dict(zip(column_names, row))
                support_list.append(support_dict)
            return support_list, True
        except Exception as e:
            print("support exception",file=sys.stderr)
            print(e)
            return [], False