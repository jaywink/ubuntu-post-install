#!/usr/bin/env python

import ConfigParser
import sys
import os

config = ConfigParser.RawConfigParser()
config.read(os.environ['HOME']+'/.local/share/applications/mimeapps.list')

changed = False
try:
    if config.get('Default Applications', sys.argv[1]) != sys.argv[2]:
        config.set('Default Applications', sys.argv[1], sys.argv[2])
        changed = True
except ConfigParser.NoOptionError:
    config.set('Default Applications', sys.argv[1], sys.argv[2])
    changed = True

if changed:
    with open(os.environ['HOME']+'/.local/share/applications/mimeapps.list', 'wb') as configfile:
        config.write(configfile)