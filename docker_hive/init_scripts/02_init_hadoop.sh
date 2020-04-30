#!/usr/bin/bash

hdfs namenode -format

start-dfs.sh
start-yarn.sh

hdfs dfs -mkdir /tmp
hdfs dfs -chown 1777 /tmp
hdfs dfs -mkdir -p /user/hadoop
