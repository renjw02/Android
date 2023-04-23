# API

## user部分

```
所有接口路径均以"/api/user"开头
```

> 用户信息
>
> + id				  系统默认分配，用户没有权限修改
> + username	只能大小写字母、数字、*-_@，5-15字符
> + password    必须字母+数字，不能有其他，6-16字符
> + nickname    任意，1-14字符
> + profile      任意

### 注册

```
@bp.route('register', methods=['POST'])
def user_register():
```

+ 接收：json

  ```
  {
  	"username"    只能大小写字母、数字、*-_@
  	"password"    必须字母+数字，不能有其他
  	"nickname"    任意，不超过14字符
  }
  ```

+ 返回：json + 状态码

  ```
  {
  	"message"	
  	"userId"
  	"username"
  	"nickname"
  }
  ```

### 登陆

```
@bp.route('/login', methods=['POST'])
def login():
```

+ 接收：json

  ```
   {
    	"username" 
    	"password" 
    }
  ```

+ 返回：json + 状态码

  ```
  {
  	"message"
  	"jwt"		此后所有访问都应在header带有Authentication字段
  	"userId"
  	"username"
  	"nickname"
  }
  ```

  

### 登出

```
@bp.route('/logout', methods=['POST'])
@login_required
def logout():
```

+ 返回：json + 状态码

  ```
  {
  	"message"
  }
  ```

  

### 修改属性

```
@bp.route('/changeattr', methods=['POST'])
@login_required
def change_attr():
```

+ 接收：json

  ```
  {
  	"username"
  	"nickname"
  	"profile"
  }
  ```

+ 返回：json + 状态码

  ```
  {
  	"message"
  	"username"
  	"nickname"
  	"profile"
  }
  ```

  

### 获取当前登陆用户信息

```
@bp.route('/user', methods=['GET'])
@login_required
def get_user_info():
```

+ 返回：json + 状态码

  ```
  {
  	"id"
  	"username"
  	"nickname"
  	"created"
  	"profile"
  }
  ```

  

### 获取指定用户信息

```
@bp.route('/user/<int:userId>', methods=['GET'])
@login_required
def get_user_info_by_id(userId):
```

+ 接收：整形整数userId

+ 返回：json + 状态码

  ```
  {
  	"id"
  	"nickname"
  	"created"
  	"profile"
  }
  ```

  

### 重置密码

```
@bp.route('/resetpw', methods=['POST'])
def reset_password():
```

+ 接收：json

  ```
  {
  	"username"
  	"password"
  }
  ```

+ 返回：json + 状态码

  ```
  {
  	"message"
  	"userId"
  }
  ```

  

### 上传头像

```
@bp.route('/uploadavatar', methods=['POST'])
@login_required
def upload_avatar():
```

+ 接受：formdata形式传file文件流

+ 返回：json + 状态码

  ```
  {
  	"message"
  }
  ```

  

### 获取头像

```
@bp.route('/downloadavatar', methods=['GET'])
@login_required
def download_avatar():
```

+ 接受：参数”name“，头像名字，对应该用户的id
+ 返回：.jpg文件



### 关注用户

```
@bp.route('/followuser/<int:userId>',methods=['POST'])
@login_required
def follow_user(userId):
```

+ 接受：userId

+ 返回：json + 状态码

  ```
  {
  	"message"
  	"followed"
  }
  "followed"键对应的值是一个字典，内容如下：
  {
  	"id"
  	"user_id"			用户id
  	"followed_id"		被user_id关注的用户的id
  }
  ```



### 取消关注

```
@bp.route('/cancelfollow/<int:followId>',methods=['POST'])
@login_required
def cancel_follow(followId):
```

+ 接受：followId

+ 返回：json + 状态码

  ```
  {
  	"message"
  }
  ```

  

### 获取已关注用户列表

```
@bp.route('/getfollowedlist/<int:userId>', methods=['GET'])
@login_required
def get_followed_list(userId):
```

+ 接受：userId

+ 返回：json + 状态码

  ```
  {
  	"message"
  	"followedList"
  	"totalNum"
  }
  "followedList"键对应的值是一个字典列表，每一个字典元素内容如下：
  {
  	"followId"
  	"followedUserId"			被关注的用户id
  	"nickname"					被关注的用户的nickname
  	"profile"					被关注的用户的profile
  }
  ```



### 获取关注我的用户列表

```
@bp.route('/getfollowerlist', methods=['GET'])
@login_required
def get_follower_list():
```

+ 接受：无

+ 返回：json + 状态码

  ```
  {
  	"message"
  	"followerList"
  	"totalNum"
  }
  "followerList"键对应的值是一个字典列表，每一个字典元素内容如下：
  {
  	"followId"
  	"followerId"				关注我的用户id
  	"nickname"					关注我的用户的nickname
  	"profile"					关注我的用户的profile
  }
  ```



### 拉黑用户

```
@bp.route('/blockuser/<int:userId>',methods=['POST'])
@login_required
def block_user(userId):
```

+ 接受：userId

+ 返回：json + 状态码

  ```
  {
  	"message"
  	"blocked"
  }
  "blocked"键对应的值是一个字典，内容如下：
  {
  	"id"
  	"user_id"			用户id
  	"blocked_id"		被user_id拉黑的用户的id
  }
  ```



### 取消拉黑

```
@bp.route('/cancelblock/<int:blockId>',methods=['POST'])
@login_required
def cancel_block(blockId):
```

+ 接受：blockId

+ 返回：json + 状态码

  ```
  {
  	"message"
  }
  ```



### 获取已拉黑用户列表

```
@bp.route('/getblockedlist/<int:userId>', methods=['GET'])
@login_required
def get_blocked_list(userId):
```

+ 接受：userId

+ 返回：json + 状态码

  ```
  {
  	"message"
  	"blockedList"
  	"totalNum"
  }
  "blockedList"键对应的值是一个字典列表，每一个字典元素内容如下：
  {
  	"blockId"
  	"blockedUserId"				被拉黑的用户id
  	"nickname"					被拉黑的用户的nickname
  	"profile"					被拉黑的用户的profile
  }
  ```



## post部分

```
所有接口路径均以"/api/post"开头
```

>post
>
>+ id               帖子id
>+ user_id             发帖用户id
>+ title                帖子标题   小于128
>+ content           帖子内容    小于1024
>+ last_replied_user_id         最后回复用户id
>+ last_replied_time          最后回复时间
>+ created          创建时间
>+ updated          更新时间
>+ type              类型  只有1，2
>+ position         位置
>+ support_num             点赞数
>+ comment_num             评论数
>+ star_num        收藏数

> comment
>
> + id                 回复id
> + user_id             发帖用户id
> + post_id             回复帖子id
> + comment_id            回复回复id，若回复的是帖子则此项置为0
> + content           帖子内容    小于1024
> + created          创建时间
> + updated          更新时间

### 创建帖子

```
@bp.route('/createpost', methods=['POST'])
@login_required
def create_post():
```

+ 接收：formdata

  ```
  文本字段：
  'title'
  'content'
  'type'
  'position'
  
  文件字段：
  视频或者图片，字节流
  ```

+ 返回：json + 状态码

  ```
  {
  	"postId"
  	"userId"
  	"title"
  	"content"
  	"hasPicture"
  	"hasVideo"
  	"message"
  }
  ```

  

### 获取指定帖子信息

```
@bp.route('/getpost/<int:postId>', methods=['GET'])
@login_required
def get_post_detail(postId):
```

+ 接受：整形整数postId

+ 返回：json + 状态码

  ```
  {
  	"message"
  	"post"
  	"images"
  	"videos"
  }
  其中post是字典，包含内容如下：
  {
  	"id"
  	"userId"
  	"nickname"
  	"title"
  	"content"
  	"supportNum"
  	"starNum"
  	"commentNum"
  	"created"
  	"updated"
  	"hasPicture"
  	"hasVideo"
  	"lastRepliedTime"
  	"comments"
  }
  其中，comment是字典列表，每一项字典元素包含内容如下：
  {
  	"id"
  	"userId"
  	"nickname"
  	"postId"
  	"commentId"
  	"content"
  	"created"
  	"updated"
  }
  images和videos分别是图片流和视频流数组
  ```

  

### 获取一页的帖子

```
@bp.route('/getpostlist', methods=['GET'])
@login_required
def get_post_list():
```

+ 接受：

  + page		将要显示第几页       默认为1         int
  + size          一页有几个帖子       默认为10       int
  + userId     显示指定用户的帖子   默认为0，即不指定用户         int
  + orderByWhat      显示顺序，默认为None，按创建时间排序，可选参数为"post.support_num", "post.comment_num"
  + type       只看type类型的帖子，默认为0，不分类型，可传入1或2
  + onlyFollowing     只看关注者的帖子，默认为False，只要传入内容就认定为True
  + hot        只看点赞过10且评论过5的帖子，默认为False，只要传入内容就认定为True

+ 返回：json+状态码

  ```
  {
  	"posts"
  	"page"
  	"size"
  	"total"
  }
  其中posts为字典列表，每一项字典元素内容包括：
  {
  	"id"
  	"userId"
  	"nickname"
  	"title"
  	"content"
  	"supportNum"
  	"starNum"
  	"commentNum"
  	"created"
  }
  ```

  

### 修改帖子

```
@bp.route('/modifypost/<int:postId>', methods=['POST'])
@login_required
def modify_post(postId):
```

+ 接收：整形整数postId，json

  ```
  {
  	"title"
  	"content"
  	"position"
  }
  ```

+ 返回：json + 状态码

  ```
  {
  	"message"
  }
  ```

  

### 删除帖子

```
@bp.route('/deletepost/<int:postId>', methods=['POST'])
@login_required
def delete_post(postId):
```

+ 接收：整形整数postId

+ 返回：json + 状态码

  ```
  {
  	"message"
  }
  ```

  

### 回复帖子

```
@bp.route('/createcomment/<int:postId>', methods=['POST'])
@login_required
def comment_post(postId):
```

+ 接收：整形整数postId,  json

  ```
  {
  	"content"
  	"commentId"		目前应该不传入该项，该项是对评论进行评论
  }
  ```

+ 返回：json + 状态码

  ```
  {
  	"message"
  }
  ```

  

### 获取回复

```
@bp.route('/getcomment/<int:commentId>', methods=['GET'])
@login_required
def get_comment(commentId):
```

+ 接收：整形整数replyId

+ 返回：json + 状态码

  ```
  {
  	"message"
  	"id"
  	"userId"
  	"postId"
  	"content"
  	"created"
  }
  ```

  

### 修改回复

```
@bp.route('/modify/<int:postId>/comment/<int:commentId>', methods=['POST'])
@login_required
def modify_comment(postId, commentId):
```

+ 接收：整形整数postId，整形整数commentId，json

  ```
  {
  	"content"
  }
  ```

+ 返回：json + 状态码

  ```
  {
  	"message"
  }
  ```



### 点赞帖子（发现问题）

```
@bp.route('/supportpost/<int:postId>', methods=['POST'])
@login_required
def support_post(postId):
```

+ 接收：整形整数postId，json

  ```
  {
  	"type"    整形，取1或-1，1表示点赞，-1表示取消点赞
  }
  ```

+ 返回：json + 状态码

  ```
  {
  	"message"
  }
  ```



### 搜索帖子（可能有问题，需要测试）

```
@bp.route('/searchpost', methods=['GET'])
@login_required
def search_post(postId):
```

+ 接收：整形整数postId，json

  ```
  {
  	"keywords"      以空格为分隔的关键词字符串
  }
  ```

+ 返回：json + 状态码

  ```
  {
  	"message"
  	"postList"
  }
  ```



## star部分

```
所有接口路径均以"/api/post"开头
```

> + id
> + user_id
> + post_id
> + title
> + created

### 收藏帖子

```
@bp.route('/collectpost', methods=['POST'])
@login_required
def collect_post():
```

+ 接收：json

  ```
  {
  	"post_id"
  	"user_id"
  	"title"
  }
  ```

+ 返回：json + 状态码

  ```
  {
  	"message"
  	"collectionId"
  	"postId"
  	"userId"
  	"created"
  }
  ```

  

### 获取收藏列表

```
@bp.route('/getcollectionlist/<int:userId>', methods=['GET'])
@login_required
def get_collection_list(userId):
```

+ 接收：整形整数userId

+ 返回：json + 状态码

  ```
  {
  	"message"
  	"collectionList"
  	"totalNum"
  }
  其中，collectionList是字典列表，每一项字典元素包括：
  {
  	"starId"
  	"postId"
  	"postTitle"
  	"created"
  }
  ```

  

### 取消收藏

```
@bp.route('/cancelcollection', methods=['POST'])
@login_required
def cancel_collection():
```

+ 接收：json

  ```
  {
  	"post_id"
  	"collection_id"
  }
  ```

+ 返回：json + 状态码

  ```
  {
  	"message"
  }
  ```

  

## notice部分

```
所有接口路径均以"/api/notice"开头
```

> + id
> + user_id
> + content
> + type        0 系统消息         1 私信
> + created
> + has_checked

### 创建通知

```
@bp.route('/createnotice', methods=['POST'])
def createnotice():
```

+ 接收：json

  ```
  {
  	"user_id"
  	"content"
  	"type"
  }
  ```

+ 返回：json + 状态码

  ```
  {
  	"message"
  	"noticeType"
  	"noticeId"
  }
  ```



### 删除通知

```
@bp.route('/removenotice/<int:noticeId>', methods=['POST'])
@login_required
def remove_notice(noticeId):
```

+ 接收：整形整数noticeId

+ 返回：json + 状态码

  ```
  {
  	"message"
  }
  ```

  

### 获取私信列表

```
@bp.route('/getnoticelist/<int:userId>', methods=['GET'])
@login_required
def get_notice_list(userId):
```

+ 接收：整形整数userId

+ 返回：json + 状态码

  ```
  {
  	"message"
  	"noticeList"
  	"totalNum"
  }
  其中noticeList是字典列表，每一项字典元素包含：
  {
  	"noticeId"
  	"userId"
  	"noticeType"
  	"noticeCreator"
  	"created"
  	"hasChecked"
  }
  ```



### 获取私信内容

```
@bp.route('/getnotice/<int:noticeId>', methods=['GET'])
@login_required
def get_notice(noticeId):
```

+ 接收：整形整数noticeId

+ 返回：json + 状态码

  ```
  {
  	"message"
  	"noticeId"
  	"content"
  	"type"
  	"creator"
  	"created"
  }
  其中noticeList是字典列表，每一项字典元素包含：
  {
  	"noticeId"
  	"userId"
  	"noticeType"
  	"noticeCreator"
  	"created"
  	"hasChecked"
  }
  ```



### 获取未读私信数量

```
@bp.route('/getunreadnum/<int:userId>', methods=['GET'])
@login_required
def get_unread_num(userId):
```

+ 接收：整形整数userId

+ 返回：json + 状态码

  ```
  {
  	"message"
  	"unreadNum"
  }
  ```



## message部分

```
所有接口路径均以"/api/message"开头
```

> + id
> + sender_id
> + receiver_id
> + content
> + created

### 创建私信

```
@bp.route('/createmessage', methods=['POST'])
@login_required
def create_message():
```

+ 接收：json

  ```
  {
  	"sender_id"
  	"receiver_id"
  	"content"
  }
  ```

+ 返回：json + 状态码

  ```
  {
  	"message"
  	"messageId"
  	"content"
  	"sendTime"
  }
  ```



### 获取历史对话

```
@bp.route('/gethistory/<int:user1Id>/<int:user2Id>', methods=['GET'])
@login_required
def get_history(user1Id, user2Id):
```

+ 接收：整形整数user1Id， user2Id

+ 返回：json + 状态码

  ```
  {
  	"message"
  	"history"
  	"totalNum"
  }
  其中history是字典列表，每一项字典元素包含：
  {
  	"id"
  	"sender_id"
  	"receiver_id"
  	"content"
  	"created"
  }
  ```



### 获取私信内容

```
@bp.route('/getnotice/<int:noticeId>', methods=['GET'])
@login_required
def get_notice(noticeId):
```

+ 接收：整形整数noticeId

+ 返回：json + 状态码

  ```
  {
  	"message"
  	"noticeId"
  	"content"
  	"type"
  	"creator"
  	"created"
  }
  其中noticeList是字典列表，每一项字典元素包含：
  {
  	"noticeId"
  	"userId"
  	"noticeType"
  	"noticeCreator"
  	"created"
  	"hasChecked"
  }
  ```


