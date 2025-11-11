resource "aws_route53_record" "rko-router-rk-n_A" {
  zone_id  = each.value
  for_each = local.rubykaigi_net_zones
  name     = "rko-router.rubykaigi.net."
  type     = "A"
  alias {
    name                   = aws_cloudfront_distribution.rko-router.domain_name
    zone_id                = aws_cloudfront_distribution.rko-router.hosted_zone_id
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "rko-router-rk-n_AAAA" {
  zone_id  = each.value
  for_each = local.rubykaigi_net_zones
  name     = "rko-router.rubykaigi.net."
  type     = "AAAA"
  alias {
    name                   = aws_cloudfront_distribution.rko-router.domain_name
    zone_id                = aws_cloudfront_distribution.rko-router.hosted_zone_id
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "rko-router-rk-n_HTTPS" {
  for_each = local.rubykaigi_net_zones
  name     = "rko-router.rubykaigi.net."
  zone_id  = each.value
  type     = "HTTPS"
  alias {
    name                   = aws_cloudfront_distribution.rko-router.domain_name
    zone_id                = aws_cloudfront_distribution.rko-router.hosted_zone_id
    evaluate_target_health = true
  }
}

data "aws_route53_zone" "rubykaigi-net_public" {
  name         = "rubykaigi.net."
  private_zone = false
}

data "aws_route53_zone" "rubykaigi-net_private" {
  name         = "rubykaigi.net."
  private_zone = true
}

locals {
  rubykaigi_net_zones = toset([data.aws_route53_zone.rubykaigi-net_public.zone_id, data.aws_route53_zone.rubykaigi-net_private.zone_id])
}
