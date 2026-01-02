# Event-Driven Data Processing Pipeline on AWS

## 📋 Project Overview

This project implements a **complete, production-ready, event-driven data processing pipeline** on AWS using serverless services. The pipeline automatically captures incoming data, processes it, and generates daily summary reports without any manual intervention.

### Key Features

- ✅ **Fully Automated**: No manual steps required after deployment
- ✅ **Event-Driven Architecture**: Real-time processing triggered by data uploads
- ✅ **Serverless**: Uses AWS Lambda, S3, and EventBridge (no servers to manage)
- ✅ **Infrastructure as Code**: Complete Terraform configuration
- ✅ **CI/CD Pipeline**: Automated deployment via GitHub Actions
- ✅ **Production-Ready**: Includes error handling, logging, and monitoring

---

## 🏗️ Architecture

### High-Level Architecture Diagram

```
┌─────────────┐
│   Data      │
│   Upload    │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────┐
│   S3 Raw Data Bucket            │
│   (Triggers Lambda)             │
└──────┬──────────────────────────┘
       │
       │ S3 Event Notification
       ▼
┌─────────────────────────────────┐
│   Lambda: process_data          │
│   - Reads file                  │
│   - Counts records              │
│   - Extracts metadata           │
└──────┬──────────────────────────┘
       │
       │ Stores processed data
       ▼
┌─────────────────────────────────┐
│   S3 Reports Bucket             │
│   (processed/ directory)        │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│   EventBridge (Daily Schedule)  │
│   Cron: 0 0 * * ? * (00:00 UTC) │
└──────┬──────────────────────────┘
       │
       │ Daily Trigger
       ▼
┌─────────────────────────────────┐
│   Lambda: daily_report          │
│   - Scans processed files        │
│   - Generates summary           │
└──────┬──────────────────────────┘
       │
       │ Saves report
       ▼
┌─────────────────────────────────┐
│   S3 Reports Bucket             │
│   (daily-reports/ directory)    │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│   CloudWatch Logs               │
│   (Monitoring & Debugging)      │
└─────────────────────────────────┘
```

### Components

1. **S3 Buckets**
   - `raw-data-bucket`: Stores incoming raw data files
   - `reports-bucket`: Stores processed data and daily reports

2. **Lambda Functions**
   - `process_data`: Triggered by S3 uploads, processes files in real-time
   - `daily_report`: Triggered daily by EventBridge, generates summary reports

3. **EventBridge Rule**
   - Scheduled to trigger daily at 00:00 UTC
   - Invokes `daily_report` Lambda function

4. **CloudWatch Logs**
   - Automatic logging for all Lambda functions
   - 7-day retention for process_data logs
   - 30-day retention for daily_report logs

5. **IAM Roles & Policies**
   - Least-privilege access for Lambda functions
   - S3 read/write permissions
   - CloudWatch logging permissions

---

## 🔄 Event Flow

### 1. Data Ingestion Flow

```
1. User uploads file → S3 Raw Data Bucket
2. S3 triggers process_data Lambda (automatic)
3. Lambda processes file:
   - Reads file metadata
   - Counts records
   - Extracts file information
4. Lambda saves processed data → S3 Reports Bucket (processed/)
5. CloudWatch logs capture all activity
```

### 2. Daily Report Generation Flow

```
1. EventBridge triggers daily at 00:00 UTC
2. EventBridge invokes daily_report Lambda
3. Lambda scans processed files from previous day
4. Lambda generates summary statistics:
   - Total files processed
   - Total records
   - File types breakdown
   - Processing status
5. Lambda saves report → S3 Reports Bucket (daily-reports/)
6. CloudWatch logs capture report generation
```

---

## 📁 Project Structure

```
project-root/
│
├── terraform/
│   ├── main.tf              # Main Terraform configuration
│   ├── variables.tf         # Terraform variables
│   └── outputs.tf           # Terraform outputs
│
├── lambda/
│   ├── process_data.py      # Data processing Lambda function
│   └── daily_report.py      # Daily report Lambda function
│
├── .github/
│   └── workflows/
│       └── deploy.yml       # GitHub Actions CI/CD pipeline
│
└── README.md                # This file
```

---

## 🚀 Deployment Instructions

### Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** installed (version >= 1.0)
3. **Python 3.11** (for local testing, not required for deployment)
4. **GitHub Account** (for CI/CD)
5. **AWS CLI** configured (optional, for manual testing)

### Step 1: Clone and Setup

```bash
# Clone the repository
git clone <your-repo-url>
cd event-driven-pipeline

# Navigate to terraform directory
cd terraform
```

### Step 2: Configure Terraform Variables

Edit `terraform/variables.tf` or create `terraform/terraform.tfvars`:

```hcl
aws_region   = "us-east-1"
project_name = "event-driven-pipeline"
environment  = "dev"
```

### Step 3: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the deployment plan
terraform plan

# Deploy infrastructure
terraform apply
```

After deployment, Terraform will output:
- Raw data bucket name
- Reports bucket name
- Lambda function names and ARNs
- EventBridge rule ARN

### Step 4: Configure GitHub Actions (CI/CD)

1. **Set up GitHub Secrets:**
   - Go to your GitHub repository
   - Navigate to: Settings → Secrets and variables → Actions
   - Add the following secrets:
     - `AWS_ACCESS_KEY_ID`: Your AWS access key
     - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

2. **Push to main branch:**
   ```bash
   git add .
   git commit -m "Initial deployment"
   git push origin main
   ```

3. **Monitor deployment:**
   - Go to: Actions tab in GitHub
   - Watch the workflow execute
   - Check for any errors

---

## 🧪 Testing the Pipeline

### Test 1: Data Processing

1. **Upload a test file to the raw data bucket:**
   ```bash
   # Get bucket name from Terraform output
   terraform output raw_data_bucket_name
   
   # Upload a test file
   aws s3 cp test-data.csv s3://<raw-data-bucket-name>/
   ```

2. **Verify processing:**
   - Check CloudWatch Logs for `process_data` Lambda
   - Verify processed file in reports bucket: `s3://<reports-bucket>/processed/`

### Test 2: Daily Report

1. **Trigger daily report manually:**
   ```bash
   # Get Lambda function name
   terraform output daily_report_lambda_function_name
   
   # Invoke Lambda
   aws lambda invoke \
     --function-name <daily-report-lambda-name> \
     --payload '{}' \
     response.json
   ```

2. **Verify report:**
   - Check CloudWatch Logs for `daily_report` Lambda
   - Verify report in reports bucket: `s3://<reports-bucket>/daily-reports/`

---

## 📊 Monitoring and Logging

### CloudWatch Logs

All Lambda functions automatically log to CloudWatch:

- **process_data logs**: `/aws/lambda/<project-name>-process-data`
- **daily_report logs**: `/aws/lambda/<project-name>-daily-report`

### Viewing Logs

```bash
# View recent logs for process_data
aws logs tail /aws/lambda/<project-name>-process-data --follow

# View recent logs for daily_report
aws logs tail /aws/lambda/<project-name>-daily-report --follow
```

### CloudWatch Metrics

AWS automatically tracks:
- Lambda invocations
- Lambda errors
- Lambda duration
- S3 object counts
- S3 storage size

View metrics in AWS Console: CloudWatch → Metrics

---

## 🔒 Security Best Practices

This implementation follows AWS security best practices:

1. **IAM Least Privilege**: Lambda functions have minimal required permissions
2. **S3 Bucket Security**: Public access blocked, versioning enabled
3. **Encryption**: S3 buckets use default encryption
4. **VPC Isolation**: (Optional) Can be extended to use VPC for Lambda
5. **Secrets Management**: AWS credentials stored in GitHub Secrets

---

## 🛠️ Troubleshooting

### Issue: Lambda function fails to process file

**Solution:**
1. Check CloudWatch Logs for error messages
2. Verify IAM permissions for Lambda role
3. Ensure S3 bucket names are correct in environment variables

### Issue: Daily report not generating

**Solution:**
1. Verify EventBridge rule is enabled
2. Check Lambda function permissions for EventBridge
3. Review CloudWatch Logs for `daily_report` function

### Issue: Terraform apply fails

**Solution:**
1. Verify AWS credentials are configured
2. Check Terraform version (>= 1.0)
3. Ensure AWS region is correct
4. Review error messages in terminal

### Issue: GitHub Actions deployment fails

**Solution:**
1. Verify GitHub Secrets are set correctly
2. Check AWS credentials have sufficient permissions
3. Review workflow logs in GitHub Actions tab

---

## 📈 Scalability and Fault Tolerance

### Scalability

- **Automatic Scaling**: Lambda functions scale automatically based on load
- **Concurrent Executions**: Lambda handles multiple files simultaneously
- **S3 Scalability**: S3 handles unlimited storage and requests
- **EventBridge**: Handles high-volume event processing

### Fault Tolerance

- **Retry Logic**: Lambda automatically retries failed invocations
- **Dead Letter Queues**: (Can be added) For failed processing
- **Error Handling**: Comprehensive error handling in Lambda functions
- **Logging**: All errors logged to CloudWatch for monitoring

### Performance Optimization

- **Lambda Memory**: Configured for optimal performance (256MB for process_data, 512MB for daily_report)
- **Lambda Timeout**: Set appropriately to prevent hanging
- **S3 Versioning**: Enabled for data recovery
- **CloudWatch Retention**: Configured to balance cost and debugging needs

---

## 💰 Cost Estimation

### AWS Free Tier (First 12 Months)

- **Lambda**: 1M free requests/month, 400,000 GB-seconds compute
- **S3**: 5GB storage, 20,000 GET requests, 2,000 PUT requests
- **EventBridge**: 14M custom events/month
- **CloudWatch Logs**: 5GB ingestion, 5GB storage

### Estimated Monthly Cost (After Free Tier)

For moderate usage (1000 files/day, 1MB average):
- **Lambda**: ~$0.20
- **S3 Storage**: ~$0.023/GB
- **S3 Requests**: ~$0.005 per 1000 requests
- **CloudWatch Logs**: ~$0.50/GB ingested
- **EventBridge**: Free (within limits)

**Total**: ~$5-10/month for moderate usage

---

## 🔄 Maintenance and Updates

### Updating Lambda Functions

1. Modify Python code in `lambda/` directory
2. Commit and push to main branch
3. GitHub Actions will automatically redeploy

### Updating Infrastructure

1. Modify Terraform files in `terraform/` directory
2. Run `terraform plan` to review changes
3. Run `terraform apply` to deploy changes
4. Or push to main for automatic deployment

### Adding New Features

- **New Lambda Functions**: Add to `terraform/main.tf`
- **New S3 Buckets**: Add to `terraform/main.tf`
- **New Event Rules**: Add EventBridge rules in `terraform/main.tf`

---

## 📚 Additional Resources

- [AWS Lambda Documentation](https://docs.aws.amazon.com/lambda/)
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [AWS EventBridge Documentation](https://docs.aws.amazon.com/eventbridge/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

---

## 📝 License

This project is provided as-is for educational and assignment purposes.

---

## 👥 Author

Built as a complete, production-ready solution for event-driven data processing on AWS.

---

## ✅ Assignment Checklist

- [x] AWS serverless architecture
- [x] Event-driven data processing
- [x] Automated daily reports
- [x] Terraform Infrastructure as Code
- [x] GitHub Actions CI/CD
- [x] Python Lambda functions
- [x] Comprehensive documentation
- [x] Error handling and logging
- [x] Security best practices
- [x] Scalability considerations

---

**Last Updated**: 2024

