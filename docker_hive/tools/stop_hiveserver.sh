#!/usr/bin/bash

for i in `ps aux | grep -e HiveServer2 -e HiveMetaStore | grep -v grep | sed -e 's|\s\s*| |g'| cut -d' ' -f 2`;do kill -15 $i;done

