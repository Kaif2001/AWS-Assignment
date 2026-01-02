# ============================================
# Event-Driven Data Processing Pipeline
# Main Terraform Configuration
# ============================================

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# ============================================
# S3 BUCKETS
# ============================================

# S3 bucket for storing raw incoming data
resource "aws_s3_bucket" "raw_data_bucket" {
  bucket = "${var.project_name}-raw-data-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "${var.project_name}-raw-data"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Enable versioning for raw data bucket (best practice)
resource "aws_s3_bucket_versioning" "raw_data_bucket_versioning" {
  bucket = aws_s3_bucket.raw_data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket for storing processed data and daily reports
resource "aws_s3_bucket" "reports_bucket" {
  bucket = "${var.project_name}-reports-${random_id.bucket_suffix.hex}"

  tags = {
    Name        = "${var.project_name}-reports"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Enable versioning for reports bucket
resource "aws_s3_bucket_versioning" "reports_bucket_versioning" {
  bucket = aws_s3_bucket.reports_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access for raw data bucket (security best practice)
resource "aws_s3_bucket_public_access_block" "raw_data_bucket_pab" {
  bucket = aws_s3_bucket.raw_data_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets  = true
}

# Block public access for reports bucket
resource "aws_s3_bucket_public_access_block" "reports_bucket_pab" {
  bucket = aws_s3_bucket.reports_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets  = true
}

# Random ID for unique bucket naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# ============================================
# IAM ROLES AND POLICIES
# ============================================

# IAM role for data processing Lambda function
resource "aws_iam_role" "process_data_lambda_role" {
  name = "${var.project_name}-process-data-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-process-data-lambda-role"
    Environment = var.environment
  }
}

# IAM role for daily report Lambda function
resource "aws_iam_role" "daily_report_lambda_role" {
  name = "${var.project_name}-daily-report-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-daily-report-lambda-role"
    Environment = var.environment
  }
}

# IAM policy for process_data Lambda: Read from raw bucket, write to reports bucket, and CloudWatch logs
resource "aws_iam_role_policy" "process_data_lambda_policy" {
  name = "${var.project_name}-process-data-lambda-policy"
  role = aws_iam_role.process_data_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "${aws_s3_bucket.raw_data_bucket.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "${aws_s3_bucket.reports_bucket.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# IAM policy for daily_report Lambda: Read from reports bucket, write reports, and CloudWatch logs
resource "aws_iam_role_policy" "daily_report_lambda_policy" {
  name = "${var.project_name}-daily-report-lambda-policy"
  role = aws_iam_role.daily_report_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = [
          aws_s3_bucket.reports_bucket.arn,
          "${aws_s3_bucket.reports_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "${aws_s3_bucket.reports_bucket.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# ============================================
# LAMBDA FUNCTIONS
# ============================================

# Lambda function for processing incoming data files
resource "aws_lambda_function" "process_data" {
  filename         = "../lambda/process_data.zip"
  function_name    = "${var.project_name}-process-data"
  role            = aws_iam_role.process_data_lambda_role.arn
  handler         = "process_data.lambda_handler"
  runtime         = "python3.11"
  timeout         = 60
  memory_size     = 256

  source_code_hash = data.archive_file.process_data_zip.output_base64sha256

  environment {
    variables = {
      REPORTS_BUCKET = aws_s3_bucket.reports_bucket.id
      RAW_BUCKET     = aws_s3_bucket.raw_data_bucket.id
    }
  }

  tags = {
    Name        = "${var.project_name}-process-data"
    Environment = var.environment
  }
}

# Lambda function for generating daily summary reports
resource "aws_lambda_function" "daily_report" {
  filename         = "../lambda/daily_report.zip"
  function_name    = "${var.project_name}-daily-report"
  role            = aws_iam_role.daily_report_lambda_role.arn
  handler         = "daily_report.lambda_handler"
  runtime         = "python3.11"
  timeout         = 300
  memory_size     = 512

  source_code_hash = data.archive_file.daily_report_zip.output_base64sha256

  environment {
    variables = {
      REPORTS_BUCKET = aws_s3_bucket.reports_bucket.id
    }
  }

  tags = {
    Name        = "${var.project_name}-daily-report"
    Environment = var.environment
  }
}

# Archive Lambda function code for process_data
data "archive_file" "process_data_zip" {
  type        = "zip"
  source_file = "../lambda/process_data.py"
  output_path = "../lambda/process_data.zip"
}

# Archive Lambda function code for daily_report
data "archive_file" "daily_report_zip" {
  type        = "zip"
  source_file = "../lambda/daily_report.py"
  output_path = "../lambda/daily_report.zip"
}

# ============================================
# EVENT TRIGGERS
# ============================================

# S3 event notification: Trigger process_data Lambda when file is uploaded to raw bucket
resource "aws_s3_bucket_notification" "raw_data_bucket_notification" {
  bucket = aws_s3_bucket.raw_data_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.process_data.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ""
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke_process_data]
}

# Permission for S3 to invoke process_data Lambda
resource "aws_lambda_permission" "allow_s3_invoke_process_data" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_data.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw_data_bucket.arn
}

# EventBridge rule: Trigger daily_report Lambda once per day at 00:00 UTC
resource "aws_cloudwatch_event_rule" "daily_report_schedule" {
  name                = "${var.project_name}-daily-report-schedule"
  description         = "Trigger daily report generation at midnight UTC"
  schedule_expression = "cron(0 0 * * ? *)"  # Every day at 00:00 UTC

  tags = {
    Name        = "${var.project_name}-daily-report-schedule"
    Environment = var.environment
  }
}

# EventBridge target: Point the rule to daily_report Lambda
resource "aws_cloudwatch_event_target" "daily_report_target" {
  rule      = aws_cloudwatch_event_rule.daily_report_schedule.name
  target_id = "DailyReportTarget"
  arn       = aws_lambda_function.daily_report.arn
}

# Permission for EventBridge to invoke daily_report Lambda
resource "aws_lambda_permission" "allow_eventbridge_invoke_daily_report" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.daily_report.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_report_schedule.arn
}

# ============================================
# CLOUDWATCH LOG GROUPS
# ============================================

# CloudWatch log group for process_data Lambda
resource "aws_cloudwatch_log_group" "process_data_logs" {
  name              = "/aws/lambda/${aws_lambda_function.process_data.function_name}"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-process-data-logs"
    Environment = var.environment
  }
}

# CloudWatch log group for daily_report Lambda
resource "aws_cloudwatch_log_group" "daily_report_logs" {
  name              = "/aws/lambda/${aws_lambda_function.daily_report.function_name}"
  retention_in_days = 30

  tags = {
    Name        = "${var.project_name}-daily-report-logs"
    Environment = var.environment
  }
}

