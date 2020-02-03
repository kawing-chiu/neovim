"""Helper functions for ultisnips"""
import time
import vim


def is_ascii(s):
    return all(ord(c) < 128 for c in s)


def get_indent(snip, shift=1):
    old = snip.rv
    snip.rv += "\n"
    snip.shift(shift)
    indent = snip.mkline()
    snip.rv = old
    return indent


def refresh(snip):
    snip.rv += ""


def add_str(snip, string):
    refresh(snip)
    snip.rv += string


def add_str_if(snip, cond, string):
    refresh(snip)
    if cond:
        snip.rv += string
    refresh(snip)


def add_str_if_not_beginswith(snip, tabstop, char, string):
    if tabstop:
        if not tabstop.startswith(char):
            snip.rv += string
    refresh(snip)


def get_buffer_file():
    return vim.current.buffer.name
