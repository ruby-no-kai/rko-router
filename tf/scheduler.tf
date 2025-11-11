resource "aws_scheduler_schedule" "rko-router-wakeup" {
  name = "rko-router-wakeup"

  flexible_time_window {
    mode                      = "FLEXIBLE"
    maximum_window_in_minutes = 90
  }

  schedule_expression = "rate(12 hours)"

  target {
    arn      = aws_lambda_function.rko-router.arn
    role_arn = aws_iam_role.SchedulerRkoRouter.arn
    input    = jsonencode({ action = "wake-up" })
  }
}
