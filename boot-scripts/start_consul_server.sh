#!/bin/sh

echo "* * * * * ps -fwwe | grep -q \"[c]onsul agent\" || { nohup consul agent -config-dir /etc/consul/ & }" | crontab
