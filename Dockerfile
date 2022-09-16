FROM public.ecr.aws/nginx/nginx:1.23
RUN apt-get update \
  && apt-get install -y --no-install-recommends ruby \
  && rm -rf /var/lib/apt/lists/*
COPY docker-entrypoint.d.sh /docker-entrypoint.d/rko-router.sh
COPY config/nginx.conf.erb /etc/nginx/nginx.conf.erb
COPY config/force_https.conf /etc/nginx/force_https.conf
RUN /docker-entrypoint.d/rko-router.sh
