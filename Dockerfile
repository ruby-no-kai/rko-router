FROM public.ecr.aws/nginx/nginx:1.29

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
     apt-get update \
  && apt-get install -y --no-install-recommends ruby

COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.9.1 /lambda-adapter /opt/extensions/lambda-adapter

RUN apt-get update \
  && apt-get install -y --no-install-recommends ruby \
  && rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.d.sh /docker-entrypoint.d/rko-router.sh
COPY config/nginx.conf.erb /etc/nginx/nginx.conf.erb
COPY config/force_https.conf /etc/nginx/force_https.conf
RUN /docker-entrypoint.d/rko-router.sh
RUN nginx -c /etc/nginx/nginx.conf

ENV AWS_LWA_PORT 8080
ENV AWS_LWA_READINESS_CHECK_PATH /healthz
ENV AWS_LWA_PASS_THROUGH_PATH /_events

ENV PRIMARY_HOST rko-router.rubykaigi.org
EXPOSE 8080
