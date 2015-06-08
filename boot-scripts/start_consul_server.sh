#!/bin/sh

nohup consul agent -server -syslog -data-dir /opt/consul &
