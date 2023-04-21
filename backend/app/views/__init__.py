from . import user, message, notice, post, star

blueprints = [
    user.bp,
    post.bp,
    star.bp,
    notice.bp,
    message.bp
    ]

def init_blueprints(app):
    for blueprint in blueprints:
        app.register_blueprint(blueprint)