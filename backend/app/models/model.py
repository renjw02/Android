from app.extension import db

class User(db.Model):
    """
    论坛用户
    """
    __tablename__ = 'user'

    id = db.Column(db.Integer, primary_key=True,
                   autoincrement=True, doc="用户id")

    username = db.Column(db.String(16), unique=True, doc="账号")
    password = db.Column(db.String(16), doc="密码")
    nickname = db.Column(db.String(16), doc="用户名称")

    # status = db.Column(db.Integer, doc="登录状态")

    profile = db.Column(db.String(255), doc="用户简介")
    avatar = db.Column(db.String(255), doc="头像路径")

    created = db.Column(db.DateTime, doc="创建时间")
    updated = db.Column(db.DateTime, doc="更新时间")

class Follow(db.Model):
    """
    关注
    """
    __tablename__ = 'follow'

    id = db.Column(db.Integer, primary_key=True,
                   autoincrement=True, doc="id")

    user_id = db.Column(db.Integer, doc="用户id")
    followed_id = db.Column(db.Integer, doc="被关注者id")

class Blacklist(db.Model):
    """
    黑名单
    """
    __tablename__ = 'blacklist'

    id = db.Column(db.Integer, primary_key=True,
                   autoincrement=True, doc="id")

    user_id = db.Column(db.Integer, doc="用户id")
    blocked_id = db.Column(db.Integer, doc="被拉黑id")

class Post(db.Model):
    """
    帖子
    """
    __tablename__ = 'post'

    id = db.Column(db.Integer, primary_key=True,
                   autoincrement=True, doc="id")
    
    user_id = db.Column(db.Integer, doc="用户id")

    title = db.Column(db.String(30), doc="标题")
    content = db.Column(db.String(1024), doc="内容")
    type = db.Column(db.Integer, doc="类型")

    position = db.Column(db.String(64), doc="位置")
    support_num = db.Column(db.Integer, doc="点赞数")
    comment_num = db.Column(db.Integer, doc="评论数")
    star_num = db.Column(db.Integer, doc="收藏数")

    created = db.Column(db.DateTime, doc="创建时间")
    updated = db.Column(db.DateTime, doc="更新时间")

    has_picture = db.Column(db.Boolean, doc="图片有无")
    has_video = db.Column(db.Boolean, doc="视频有无")

class Comment(db.Model):
    """
   评论
    """
    __tablename__ = 'comment'

    id = db.Column(db.Integer, primary_key=True,
                   autoincrement=True, doc="id")
    
    user_id = db.Column(db.Integer, doc="用户id")
    post_id = db.Column(db.Integer, doc="帖子id")
    comment_id = db.Column(db.Integer, doc="评论id")
    
    content = db.Column(db.String(1024), doc="内容")

    created = db.Column(db.DateTime, doc="创建时间")
    updated = db.Column(db.DateTime, doc="更新时间")

class Star(db.Model):
    """
    收藏
    """
    __tablename__ = 'star'

    id = db.Column(db.Integer, primary_key=True,
                   autoincrement=True, doc="收藏id")

    user_id = db.Column(db.Integer, doc="用户id")
    post_id = db.Column(db.Integer, doc="帖子id")
    
    title = db.Column(db.String(255), doc="标题")

class Picture(db.Model):
    """
    图片
    """
    __tablename__ = 'picture'
    id = db.Column(db.Integer, primary_key=True,
                   autoincrement=True, doc="id")
    
    post_id = db.Column(db.Integer, doc="帖子id")
    path = db.Column(db.String(64), doc="路径")

class Video(db.Model):
    """
    视频
    """
    __tablename__ = 'video'
    id = db.Column(db.Integer, primary_key=True,
                   autoincrement=True, doc="id")
    
    post_id = db.Column(db.Integer, doc="帖子id")
    path = db.Column(db.String(64), doc="路径")

class Notice(db.Model):
    """
    通知
    """
    __tablename__ = 'notice'
    id = db.Column(db.Integer, primary_key=True,
                   autoincrement=True, doc="id")
    
    user_id = db.Column(db.Integer, doc="用户id")
    content = db.Column(db.String(64), doc="通知内容")
    type = db.Column(db.Integer, doc="通知类型")

    created = db.Column(db.DateTime, doc="创建时间")
    has_checked = db.Column(db.Boolean, doc="被查看与否")

class Message(db.Model):
    """
    私信
    """
    __tablename__ = 'message'
    id = db.Column(db.Integer, primary_key=True,
                   autoincrement=True, doc="id")
    
    sender_id = db.Column(db.Integer, doc="发送者id")
    receiver_id = db.Column(db.Integer, doc="接收者id")
    content = db.Column(db.String(256), doc="通知内容")
    
    created = db.Column(db.DateTime, doc="发送时间")