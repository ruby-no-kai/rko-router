#!/bin/bash
export RKO_ROUTER_PLATFORM=docker
if [[ -n "${AWS_LAMBDA_FUNCTION_NAME}" ]]; then
  export RKO_ROUTER_PLATFORM=lambda
fi

export PORT=${PORT:-8080}
erb /etc/nginx/nginx.conf.erb > /etc/nginx/nginx.conf
