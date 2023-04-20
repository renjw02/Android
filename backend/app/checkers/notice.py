#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib


def notice_params_check(content):
    '''
    content     小于64
    '''
    # content
    if 'content' in content:
        _content = content['content']
        if len(_content) <= 0 or len(_content) > 64:
            return "content", False
    else:
        return "content", False
    
    return "ok", True
