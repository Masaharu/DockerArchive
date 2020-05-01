#!/usr/bin/bash

hive --service metastore &
hive --service hiveserver2 &

