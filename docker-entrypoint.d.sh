#!/bin/bash
export PORT=${PORT:-8080}
erb /etc/nginx/nginx.conf.erb > /etc/nginx/nginx.conf
