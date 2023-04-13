
blueprints = []

def init_blueprints(app):
    for blueprint in blueprints:
        app.register_blueprint(blueprint)