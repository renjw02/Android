#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib


def post_params_check(title, content, type_, position, font_size):
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
    
    if type_ is not None:
        if type_ != 1 and type_ != 2:
            return "type", False
    else:
        return "type", False
    
    if type(font_size) != int:
        return "font_size", False

    if position is not None:
        if len(position) <= 0 or len(position) > 64:
            return "position", False
    else:
        return "position", False
    
    return "ok", True