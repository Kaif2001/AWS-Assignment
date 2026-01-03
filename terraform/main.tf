############################################
# Event-Driven Data Processing Pipeline
# Simplified Terraform Demo Configuration
############################################

provider "aws" {
  region = "ap-south-1"
}

############################################
# S3 BUCKETS
############################################

# Raw data bucket
resource "aws_s3_bucket" "raw_data_bucket" {
  bucket = "event-driven-raw-data-demo"
}

# Reports bucket
resource "aws_s3_bucket" "reports_bucket" {
  bucket = "event-driven-reports-demo"
}

############################################
# IAM ROLE FOR LAMBDA
############################################

resource "aws_iam_role" "lambda_role" {
  name = "event-driven-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

############################################
# LAMBDA FUNCTION
############################################

resource "aws_lambda_function" "data_processor" {
  function_name = "event-driven-data-processor"
  runtime       = "python3.11"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  filename      = "lambda_function.zip"
}

############################################
# S3 EVENT TRIGGER
############################################

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.raw_data_bucket.arn
}

############################################
# NOTES
############################################
# - Data upload to S3 triggers Lambda
# - Lambda processes data
# - Output can be stored in reports bucket
# - CloudWatch logs enabled by default

