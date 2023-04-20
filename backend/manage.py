from flask_script import Manager, Server
from flask_migrate import Migrate, MigrateCommand


from app import create_app, db
from app.utils import config, encrypt_password
from app.models import User


app = create_app('default')

manager = Manager(app)
migrate = Migrate(app, db)
host = config.get_yaml('app.HOST')
port = config.get_yaml('app.PORT')

manager.add_command('runserver', Server(host=host, port=port))
manager.add_command('db', MigrateCommand)

@manager.command
def init_db():
    """Init db"""
    db.drop_all()
    db.create_all()
    me = User(username="test", password=encrypt_password(str("test")), nickname="test", mobile="45678901122")  
    db.session.add(me)
    db.session.commit()

if __name__ == '__main__':
    manager.run()