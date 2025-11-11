resource "aws_cloudfront_distribution" "rko-router" {
  provider        = aws.use1
  enabled         = true
  is_ipv6_enabled = true
  http_version    = "http2and3"
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
    origin_id   = "rko-router-lambda"
    domain_name = replace(aws_lambda_function_url.rko-router.function_url, "/^https:\\/+|\\/$/", "")

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
      origin_shield_region = "us-west-2"
    }
  }

  ordered_cache_behavior {
    path_pattern = "/_csp"

    allowed_methods        = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "rko-router-lambda"
    viewer_protocol_policy = "https-only"

    cache_policy_id            = data.aws_cloudfront_cache_policy.Managed-CachingDisabled.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.rko-router.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.rko-router-viewreq.arn
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "rko-router-lambda"
    viewer_protocol_policy = "allow-all"

    cache_policy_id            = aws_cloudfront_cache_policy.rko-router-default.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.rko-router.id

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
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
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

resource "aws_cloudfront_response_headers_policy" "rko-router" {
  name    = "rko-router"
  comment = "rko-router"

  server_timing_headers_config {
    enabled       = true
    sampling_rate = 100
  }

  # Function URL cannot return these headers directly and they get rewritten. Remove redundant headers.
  remove_headers_config {
    items {
      header = "X-Amzn-Remapped-Connection"
    }
    items {
      header = "X-Amzn-Remapped-Content-Length"
    }
    items {
      header = "X-Amzn-Remapped-Server"
    }
    items {
      header = "X-Amzn-Remapped-Date"
    }
  }
}

resource "null_resource" "tsc" {
  triggers = {
    tsdgst = join("", [
      sha256(join("", [for f in fileset("${path.module}/cf_functions", "src/**/*.ts") : filesha256("${path.module}/cf_functions/${f}")])),
      filesha256("${path.module}/cf_functions/pnpm-lock.yaml"),
    ])
  }
  provisioner "local-exec" {
    command = "cd ${path.module}/cf_functions && pnpm i && tsc -b"
  }
}

data "local_file" "viewreq" {
  filename   = "${path.module}/cf_functions/src/viewreq.js"
  depends_on = [null_resource.tsc]
}

resource "aws_cloudfront_function" "rko-router-viewreq" {
  provider = aws.use1
  name     = "rko-router-viewreq"
  comment  = "rko-router viewer-request"
  runtime  = "cloudfront-js-2.0"
  publish  = true
  code     = "${replace(data.local_file.viewreq.content, "/(?m)^export function handler/", "function handler")}\n// 1"

  depends_on = [null_resource.tsc]
}

