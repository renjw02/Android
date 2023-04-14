#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib
import datetime
from sqlalchemy import and_

from extension import db
from models.model import Star, Post

class StarService():
