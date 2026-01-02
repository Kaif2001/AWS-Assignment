# ============================================
# Terraform Outputs
# ============================================

output "raw_data_bucket_name" {
  description = "Name of the S3 bucket for raw data"
  value       = aws_s3_bucket.raw_data_bucket.id
}

output "reports_bucket_name" {
  description = "Name of the S3 bucket for reports"
  value       = aws_s3_bucket.reports_bucket.id
}

output "process_data_lambda_function_name" {
  description = "Name of the process_data Lambda function"
  value       = aws_lambda_function.process_data.function_name
}

output "daily_report_lambda_function_name" {
  description = "Name of the daily_report Lambda function"
  value       = aws_lambda_function.daily_report.function_name
}

output "process_data_lambda_arn" {
  description = "ARN of the process_data Lambda function"
  value       = aws_lambda_function.process_data.arn
}

output "daily_report_lambda_arn" {
  description = "ARN of the daily_report Lambda function"
  value       = aws_lambda_function.daily_report.arn
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule for daily reports"
  value       = aws_cloudwatch_event_rule.daily_report_schedule.arn
}

