#!/bin/sh

echo "* * * * * ps -fwwe | grep -q 'consul agent' || { nohup consul agent -config-dir /etc/consul/ & }" | crontab
