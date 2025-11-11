resource "aws_lambda_function" "rko-router" {
  function_name = "rko-router"

  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.rko-router.repository_url}:3285c10bdd196708e97523c116baeba981b8b8a7"
  architectures = ["x86_64"]

  role = aws_iam_role.LambdaRkoRouter.arn

  memory_size = 256
  timeout     = 30

  environment {
    variables = {
      AWS_LWA_INVOKE_MODE         = "response_stream"
      NGINX_ENTRYPOINT_QUIET_LOGS = "1"

      JUMP_HOST = "*.lambda-url.us-west-2.on.aws"
    }
  }

  tags = {
    Name = "rko-router"
  }

  # lifecycle {
  #   ignore_changes = [
  #     image_uri,
  #   ]
  # }
}

resource "aws_lambda_function_url" "rko-router" {
  function_name      = aws_lambda_function.rko-router.function_name
  authorization_type = "NONE"
  invoke_mode        = "RESPONSE_STREAM"
}

output "function_url" {
  value = aws_lambda_function_url.rko-router.function_url
}
