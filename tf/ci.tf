resource "aws_iam_role" "rko-router-ci" {
  name               = "GhaRkoRouter"
  description        = "rko-router tf/iam.tf"
  assume_role_policy = data.aws_iam_policy_document.rko-router-ci-trust.json
}

data "aws_iam_openid_connect_provider" "github-actions" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "rko-router-ci-trust" {
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
        "repo:ruby-no-kai/rko-router:ref:refs/heads/master",
      ]
    }
  }
}

resource "aws_iam_role_policy" "rko-router-ci-ecr" {
  role   = aws_iam_role.rko-router-access.name
  policy = data.aws_iam_policy_document.rko-router-access.json
}

resource "aws_iam_role_policy" "rko-router-ci-apprunner" {
  role   = aws_iam_role.rko-router-access.name
  policy = data.aws_iam_policy_document.rko-router-ci-apprunner.json
}

data "aws_iam_policy_document" "rko-router-ci-apprunner" {
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole",
    ]
    resources = [aws_iam_role.rko-router-access.arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "apprunner:UpdateService",
    ]
    resources = [
      aws_apprunner_service.rko-router.arn,
    ]
  }
}
