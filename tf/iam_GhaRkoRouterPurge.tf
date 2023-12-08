resource "aws_iam_role" "rko-router-purge" {
  name               = "GhaRkoRouterPurge"
  description        = "rko-router"
  assume_role_policy = data.aws_iam_policy_document.rko-router-purge-trust.json
}

data "aws_iam_policy_document" "rko-router-purge-trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github-actions.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:ruby-no-kai/rko-router:environment:apprunner-prod",
        "repo:ruby-no-kai/rubykaigi.org:environment:github-pages",
      ]
    }
  }
}

resource "aws_iam_role_policy" "rko-router-purge-ecr" {
  role   = aws_iam_role.rko-router-purge.name
  policy = data.aws_iam_policy_document.rko-router-purge-ecr.json
}

data "aws_iam_policy_document" "rko-router-purge-ecr" {
  statement {
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation",
      "cloudfront:GetInvalidation",
    ]
    resources = [
      aws_cloudfront_distribution.rko-router.arn,
    ]
  }
}
