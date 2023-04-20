#!/usr/bin/env python
# -*- encoding: utf-8 -*-

# here put the import lib


def message_params_check(content):
    '''
    content     小于256
    '''
    # content
    if 'content' in content:
        _content = content['content']
        if len(_content) <= 0 or len(_content) > 256:
            return "content", False
    else:
        return "content", False
    
    return "ok", True
