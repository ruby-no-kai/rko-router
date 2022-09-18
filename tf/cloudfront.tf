resource "aws_cloudfront_distribution" "rko-router" {
  provider        = aws.use1
  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_All"
  comment         = "rko-router"

  aliases = [
    "rko-router.rubykaigi.org",

    "rubykaigi.org",

    "2006.rubykaigi.org",
    "2007.rubykaigi.org",
    "2008.rubykaigi.org",
    "j.rubykaigi.org",
    "regional.rubykaigi.org",
    "sapporo.rubykaigi.org",
    "sponsorship.rubykaigi.org",
    "www.rubykaigi.org",
    "yami.rubykaigi.org",
  ]

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.use1-wild-rk-o.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  logging_config {
    include_cookies = false
    bucket          = "rk-aws-logs.s3.amazonaws.com"
    prefix          = "cf/rko-router.rubykaigi.org/"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  origin {
    origin_id   = "rko-router-apprunner"
    domain_name = replace(aws_apprunner_service.rko-router.service_url, "https://", "")

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 30
      origin_read_timeout      = 35
    }

    origin_shield {
      enabled              = true
      origin_shield_region = "ap-northeast-1"
    }
  }

  ordered_cache_behavior {
    path_pattern = "/_csp"

    allowed_methods        = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "rko-router-apprunner"
    viewer_protocol_policy = "https-only"

    cache_policy_id = data.aws_cloudfront_cache_policy.Managed-CachingDisabled.id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "rko-router-apprunner"
    viewer_protocol_policy = "allow-all"

    cache_policy_id = aws_cloudfront_cache_policy.rko-router-default.id

    compress = true

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.rko-router-viewreq.arn
    }
  }
}

data "aws_cloudfront_cache_policy" "Managed-CachingDisabled" {
  provider = aws.use1
  name     = "Managed-CachingDisabled"
}

resource "aws_cloudfront_cache_policy" "rko-router-default" {
  provider = aws.use1
  name     = "rko-router-default"
  comment  = "rko-router-default"

  min_ttl     = 1
  default_ttl = 86400
  max_ttl     = 31536000

  parameters_in_cache_key_and_forwarded_to_origin {
    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["x-rko-host", "x-rko-xfp", "cloudfront-forwarded-proto"]
      }
    }
    query_strings_config {
      query_string_behavior = "none"
    }
    cookies_config {
      cookie_behavior = "none"
    }
  }
}
resource "null_resource" "tsc" {
  triggers = {
    tsdgst = join("", [
      sha256(join("", [for f in fileset("${path.module}/cf_functions", "src/**/*.ts") : filesha256("${path.module}/cf_functions/${f}")])),
      filesha256("${path.module}/cf_functions/package-lock.json"),
    ])
  }
  provisioner "local-exec" {
    command = "cd ${path.module}/cf_functions && npm i && tsc -b"
  }
}

resource "aws_cloudfront_function" "rko-router-viewreq" {
  provider = aws.use1
  name     = "rko-router-viewreq"
  comment  = "rko-router viewer-request"
  runtime  = "cloudfront-js-1.0"
  publish  = true
  code     = file("${path.module}/cf_functions/src/viewreq.js")

  depends_on = [null_resource.tsc]
}

