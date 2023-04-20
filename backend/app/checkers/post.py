#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib


def post_params_check(title, content, type, position):
    '''
    title       小于128
    content     小于1024
    type        0 1
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
    
    if type is not None:
        if type != 0 or type != 1:
            return "content", False
    else:
        return "content", False
    
    if position is not None:
        if len(position) <= 0 or len(position) > 64:
            return "content", False
    else:
        return "content", False
    
    return "ok", True