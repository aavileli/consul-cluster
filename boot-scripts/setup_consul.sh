#!/bin/sh

mkdir -p /opt/consul

## set the password for nginx
htpasswd -cb /etc/nginx/.htpasswd admin $NGINX_PASSWORD

## reload nginx
/usr/sbin/nginx -s reload

(
    cd /tmp
    wget https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip
    unzip 0.5.2_linux_amd64.zip
    mv consul /usr/local/bin/
)
