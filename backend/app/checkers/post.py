#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib
import sys

def post_params_check(title, content, typei, position):
    '''
    title       小于128
    content     小于1024
    type        1 2
    position    小于64
    '''    
    # title
    if title is not None:
        if len(title) <= 0 or len(title) > 128:
            return "title", False
    else:
        return "title", False

    # content
    if content is not None:
        if len(content) <= 0 or len(content) > 1024:
            return "content", False
    else:
        return "content", False
    
    if typei is not None:
        if typei != 1 and typei != 2:
            print(typei, type(typei),file=sys.stderr)
            return "type", False
    else:
        return "type", False
    
    if position is not None:
        if len(position) <= 0 or len(position) > 64:
            return "position", False
    else:
        return "position", False
    
    return "ok", True