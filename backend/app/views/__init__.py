from . import user, message, notice, post, star,media

blueprints = [
    user.bp,
    post.bp,
    star.bp,
    notice.bp,
    message.bp,
    media.bp
    ]

def init_blueprints(app):
    for blueprint in blueprints:
        app.register_blueprint(blueprint)