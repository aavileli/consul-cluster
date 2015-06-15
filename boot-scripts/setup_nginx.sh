#!/bin/sh

mkdir -p /etc/nginx/

cat <<"EOF" > /etc/nginx/nginx.conf
user  nginx;
worker_processes  1;
error_log  /var/log/nginx/error.log;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
  server {
    listen       80;
    location / {
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_pass http://localhost:8500;
      auth_basic "Restricted";
      auth_basic_user_file /etc/nginx/.htpasswd;
    }
  }
}

EOF
chmod 755 /etc/nginx/nginx.conf
chown root:root /etc/nginx/nginx.conf

