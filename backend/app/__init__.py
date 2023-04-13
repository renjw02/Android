from flask import Flask
from flask_cors import CORS

from configs import configs
from extension import db
from views import init_blueprints
from utils import jwt_authentication

def create_app(current_config=None):
    app = Flask(__name__)
    CORS(app)

    app.config.from_object(configs[current_config])

    # authentication
    app.before_request(jwt_authentication)

    # blueprint
    init_blueprints(app)

    # db
    db.init_app(app)

    return app

