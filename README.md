# rubykaigi.org router

nginx container deployed on AWS App Runner and served through CloudFront.

## Deploy

Deployments are automatically performed on GitHub Actions on `master` branch after CI.

- App Runner: [arn:aws:apprunner:us-west-2:005216166247:service/rko-router/2c9219ae5e14411baaf46fa932f33025](https://us-west-2.console.aws.amazon.com/apprunner/home?region=us-west-2#/services/dashboard?service_arn=arn%3Aaws%3Aapprunner%3Aus-west-2%3A005216166247%3Aservice%2Frko-router%2F2c9219ae5e14411baaf46fa932f33025&active_tab=logs)
- CloudFront: [arn:aws:cloudfront::005216166247:distribution/E2WEWQCYU12GVD](https://us-east-1.console.aws.amazon.com/cloudfront/v3/home?region=ap-northeast-1#/distributions/E2WEWQCYU12GVD)

All resources except App Runner deployment is managed under Terraform (`./tf`).

### Domains

Due to the quota of custom domains per App Runner service, the first hop on rko-router proxies a request to itself with correct `Host` header.

`x-rko-host` and `x-rko-xfp` headers are referenced as a `Host` and `X-Forwarded-Proto` header for the second hop.

These custom headers are assigned at CloudFront function (viewer-request) and implementation is at [./tf/cf_functions/src/viewreq.ts](./tf/cf_functions/src/viewreq.ts).

## Run locally

```
docker build -t rko-router:latest .
docker run --rm --name rko-router --publish 127.0.0.1::8080 rko-router:latest
```

```
curl -H Host:rubykaigi.org http://$(docker port rko-router 8080)/
```

## Test

Test against production:

```
bundle exec rspec -fd ./spec
```

Test against alternate deployment:

```
bundle exec env TARGET_HOST=https://rko-router.herokuapp.com rspec -fd ./spec
```

## AWS Login

https://rubykaigi.esa.io/posts/813
