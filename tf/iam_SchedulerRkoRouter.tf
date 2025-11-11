resource "aws_iam_role" "SchedulerRkoRouter" {
  name                 = "SchedulerRkoRouter"
  description          = "rko-router//tf/iam_SchedulerRkoRouter.tf"
  assume_role_policy   = data.aws_iam_policy_document.SchedulerRkoRouter-trust.json
  max_session_duration = 3600
}

data "aws_iam_policy_document" "SchedulerRkoRouter-trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "scheduler.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy" "SchedulerRkoRouter" {
  role   = aws_iam_role.SchedulerRkoRouter.name
  policy = data.aws_iam_policy_document.SchedulerRkoRouter.json
}

data "aws_iam_policy_document" "SchedulerRkoRouter" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [
      aws_lambda_function.rko-router.arn,
    ]
  }
}
