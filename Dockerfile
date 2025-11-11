FROM public.ecr.aws/nginx/nginx:1.29

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
     apt-get update \
  && apt-get install -y --no-install-recommends ruby

COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.9.1 /lambda-adapter /opt/extensions/lambda-adapter

# Replace /etc/nginx with a temporary directory for Lambda, where /etc/nginx is read-only
# /run is for /run/nginx.pid
RUN mv /etc/nginx /etc/nginx.base \
 && rm -rf /run && ln -s /tmp/run /run \
 && ln -s /tmp/run/etc-nginx /etc/nginx \
 && rm -rf /etc/nginx.base/conf.d/default.conf \
 && rm -v /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh # We don't use conf.d/default.conf

COPY config/nginx.conf.erb /etc/nginx.base/nginx.conf.erb
COPY config/force_https.conf /etc/nginx.base/force_https.conf

COPY docker/entrypoint.d/00-rk-tmp-etc-nginx.sh /docker-entrypoint.d/
COPY docker/entrypoint.d/90-rko-router.sh /docker-entrypoint.d/

ENV AWS_LWA_PORT 8080
ENV AWS_LWA_READINESS_CHECK_PATH /healthz
ENV AWS_LWA_PASS_THROUGH_PATH /_events

ENV PRIMARY_HOST rko-router.rubykaigi.org

RUN --mount=type=tmpfs,target=/tmp/run \
    /docker-entrypoint.d/00-rk-tmp-etc-nginx.sh \
 && /docker-entrypoint.d/90-rko-router.sh \
 && nginx -c /etc/nginx/nginx.conf

EXPOSE 8080
