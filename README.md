# rubykaigi.org router

nginx container deployed on Lambda Function URL and served through CloudFront.

- Detailed docs for RubyKaigi orgz: https://rubykaigi.esa.io/posts/1241

## Quick Reference

### Add regional.rubykaigi.org subdirectory

1. Prepare GitHub Pages. No need to configure custom domain.
2. Write the following configuration to [./config/nginx.conf.erb](./config/nginx.conf.erb). Replace path, ORG_NAME and REPO_NAME with the actual value accordingly.

   Add a new location block right before `regional.rubykaigi.org` location. Leave other parts as is.

   ```nginx
   # ...

   location /penacony42 {
      include force_https.conf;
      include github_pages.conf;
      proxy_redirect https://ORG_NAME.github.io/REPO_NAME $map_request_proto://$http_host/REPO_NAME;
      proxy_pass https://ORG_NAME.github.io;
   }

   # regional.rubykaigi.org
   location / {
     # ...
   }
   ```

3. Submit a PR and wait for review.

__Cache:__ With the above configuration, our CDN respects GitHub Pages cache headers. As of Nov 2025, it is currently set to 10 minutes for everything. Contact RubyKaigi admins if you need immediate cache invalidation. We recommend to enable asset file hashing to avoid cache issues.

### Switch _the year_ of rubykaigi.org

Change the following values to the desired year. This will update `/` to redirect to the new year's website (`/YYYY/`), and serve `/#{year}` and `/#{year+1}` from the [rubykaigi.org repo](https://github.com/ruby-no-kai/rubykaigi.org). Make sure `#{year-1}` is switched to the archive beforehand.

- `current_year` value in [./config/nginx.conf.erb](./config/nginx.conf.erb)
- `latest_year` value in [./spec/rubykaigi_org_spec.rb](./spec/rubykaigi_org_spec.rb)

You'll need to invalidate CloudFront cache of root page `/` after deploy.

### Archive old rubykaigi.org year

Update `# RubyKaigi Archives` location path regex accordingly in [./config/nginx.conf.erb](./config/nginx.conf.erb).

```nginx
# RubyKaigi Archives
location ~ ^/202[2-5] {
  include force_https.conf;
  # ...
```

You'll need to invalidate CloudFront cache of the archived year `/YYYY` after deploy.


----

If you're going to do something more than the above, continue reading. Don't forget to write tests for new functionailities.

## Deploy

Deployments are automatically performed on GitHub Actions on `master` branch after CI.

- Lambda: [rko-router](https://us-west-2.console.aws.amazon.com/lambda/home?region=us-west-2#/functions/rko-router?tab=monitoring)
- CloudFront: [arn:aws:cloudfront::005216166247:distribution/E2WEWQCYU12GVD](https://us-east-1.console.aws.amazon.com/cloudfront/v3/home?region=ap-northeast-1#/distributions/E2WEWQCYU12GVD)

All resources except deployment is managed under Terraform [./tf](./tf).

### Serving multiple domains in production

Because Lambda Function URL does not support custom domains, the first hop on rko-router proxies a request to itself with correct `Host` header. We call this virtual host a _jump host._

`x-rko-host` and `x-rko-xfp` headers are referenced as a `Host` and `X-Forwarded-Proto` header for the second hop.

These custom headers are assigned at CloudFront function (viewer-request) and implementation is at [./tf/cf_functions/src/viewreq.ts](./tf/cf_functions/src/viewreq.ts).

### Cache invalidation

While rubykaigi.org deployment automatically invalidates CloudFront cache on each deployment, rko-router does not.

You need to manually invalidate the cache: https://rubykaigi.esa.io/posts/1241#%E3%82%AD%E3%83%A3%E3%83%83%E3%82%B7%E3%83%A5

## Run locally

```
docker compose up --watch
```

```
curl -H Host:rubykaigi.org http://$(docker compose port nginx 8080)/
TARGET_HOST=http://$(docker compose port nginx 8080) bundle exec rspec
```

## Test

Test against production:

```
bundle exec rspec -fd ./spec
```

Test against alternate rko-router, use `$TARGET_HOST`. This enables `x-rko-host` and `x-rko-xfp` headers when sending request. If you want to test against production, you need to specify deployment url directly (App Router service URL, Lambda function URL) instead of CNAMEs under rubykaigi domains.

```
TARGET_HOST=http://$(docker port rko-router 8080) bundle exec rspec -fd ./spec
TARGET_HOST=https://rko-router.invalid bundle exec env rspec -fd ./spec
```
