resource "aws_iam_role" "LambdaRkoRouter" {
  name               = "LambdaRkoRouter"
  description        = "rko-router//tf/lambda.tf"
  assume_role_policy = data.aws_iam_policy_document.LambdaRkoRouter-trust.json
}

data "aws_iam_policy_document" "LambdaRkoRouter-trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda-AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.LambdaRkoRouter.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


