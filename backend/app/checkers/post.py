#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib


def post_params_check(content):
    '''
    title       小于128
    content     小于1024
    '''    
    # title
    if 'title' in content:
        title = content['title']
        if len(title) <= 0 or len(title) > 128:
            return "title", False
    else:
        return "title", False

    # content
    if 'content' in content:
        _content = content['content']
        if len(_content) <= 0 or len(_content) > 1024:
            return "content", False
    else:
        return "content", False
    
    return "ok", True