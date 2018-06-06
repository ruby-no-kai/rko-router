# rubykaigi.org router


what: rko-router uses https://github.com/ryandotsmith/nginx-buildpack to build nginx on heroku.

notes: the specs exercises against real http server to verify current behaviour on the net.

## Test

Test against production:

```
bundle exec rspec -fd ./spec
```

Test against alternate deployment:

```
bundle exec env TARGET_HOST=https://rko-router.herokuapp.com rspec -fd ./spec
```
