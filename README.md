# Event-Driven Data Processing Pipeline (AWS)

## Project Overview
This project demonstrates a **simple event-driven architecture on AWS** using
serverless services. It is created for assignment and learning purposes.

The focus is on understanding:
- Event-driven design
- AWS Lambda
- Amazon S3
- Infrastructure as Code using Terraform

## Architecture Summary
1. A file is uploaded to an S3 bucket
2. S3 triggers a Lambda function
3. Lambda logs the event and confirms processing
4. Logs are visible in CloudWatch

## Files Included

### main.tf
- Terraform configuration
- Creates:
  - S3 bucket
  - Lambda function
  - S3 → Lambda trigger
- Demonstrates Infrastructure as Code

### lambdafunction.py
- Simple AWS Lambda function
- Triggered by S3 ObjectCreated event
- Logs the incoming event
- Returns success response

## Notes
- Code is intentionally kept **simple**
- This is a **demo implementation**, not production-ready
- Focus is on architecture understanding and explanation

## Author
Created as part of an AWS event-driven architecture assignment.
