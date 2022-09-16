#!/bin/bash
export RKO_ROUTER_PLATFORM=docker
export PORT=${PORT:-8080}
erb /etc/nginx/nginx.conf.erb > /etc/nginx/nginx.conf
