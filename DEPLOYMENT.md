# Quick Deployment Guide

## Prerequisites Checklist

- [ ] AWS Account created
- [ ] AWS CLI installed and configured (`aws configure`)
- [ ] Terraform installed (version >= 1.0)
- [ ] GitHub repository created
- [ ] GitHub Secrets configured (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)

## Step-by-Step Deployment

### 1. Local Setup

```bash
# Clone or navigate to project directory
cd event-driven-pipeline

# Navigate to terraform directory
cd terraform

# Copy example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values (optional)
# Default values will work if you don't edit
```

### 2. Initial Terraform Deployment

```bash
# Initialize Terraform (downloads providers)
terraform init

# Review what will be created
terraform plan

# Deploy infrastructure
terraform apply

# Type 'yes' when prompted, or use -auto-approve flag
terraform apply -auto-approve
```

### 3. Save Terraform Outputs

After deployment, save the outputs:

```bash
# Save outputs to a file
terraform output > ../outputs.txt

# Or view outputs
terraform output
```

**Important outputs to note:**
- `raw_data_bucket_name`: Use this to upload test files
- `reports_bucket_name`: Check this for processed data and reports

### 4. Configure GitHub Actions

1. **Push code to GitHub:**
   ```bash
   git add .
   git commit -m "Initial deployment"
   git push origin main
   ```

2. **Set up GitHub Secrets:**
   - Go to: GitHub Repository → Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Add:
     - Name: `AWS_ACCESS_KEY_ID`, Value: Your AWS Access Key
     - Name: `AWS_SECRET_ACCESS_KEY`, Value: Your AWS Secret Key

3. **Verify CI/CD:**
   - Go to: GitHub Repository → Actions tab
   - You should see the workflow running
   - Wait for it to complete successfully

### 5. Test the Pipeline

#### Test Data Processing

```bash
# Get the raw data bucket name
RAW_BUCKET=$(terraform output -raw raw_data_bucket_name)

# Create a test file
echo "name,age,city
John,30,New York
Jane,25,Los Angeles" > test-data.csv

# Upload to S3
aws s3 cp test-data.csv s3://$RAW_BUCKET/

# Wait a few seconds, then check CloudWatch Logs
aws logs tail /aws/lambda/event-driven-pipeline-process-data --follow
```

#### Test Daily Report

```bash
# Get the daily report Lambda name
DAILY_REPORT=$(terraform output -raw daily_report_lambda_function_name)

# Invoke manually
aws lambda invoke \
  --function-name $DAILY_REPORT \
  --payload '{}' \
  response.json

# Check the response
cat response.json

# Check reports bucket
REPORTS_BUCKET=$(terraform output -raw reports_bucket_name)
aws s3 ls s3://$REPORTS_BUCKET/processed/
aws s3 ls s3://$REPORTS_BUCKET/daily-reports/
```

## Verification Checklist

After deployment, verify:

- [ ] S3 buckets created (raw-data and reports)
- [ ] Lambda functions created (process_data and daily_report)
- [ ] EventBridge rule created and enabled
- [ ] IAM roles and policies attached
- [ ] CloudWatch log groups created
- [ ] Test file processing works
- [ ] Daily report generation works (manual test)

## Troubleshooting

### Terraform Errors

**Error: "Provider not found"**
```bash
terraform init
```

**Error: "Access Denied"**
- Check AWS credentials: `aws sts get-caller-identity`
- Verify IAM permissions

**Error: "Bucket name already exists"**
- S3 bucket names are globally unique
- Change `project_name` in variables.tf

### Lambda Errors

**Check CloudWatch Logs:**
```bash
aws logs tail /aws/lambda/event-driven-pipeline-process-data --follow
aws logs tail /aws/lambda/event-driven-pipeline-daily-report --follow
```

**Common Issues:**
- Missing environment variables → Check Lambda configuration
- Permission errors → Check IAM roles
- Timeout errors → Increase Lambda timeout in Terraform

### GitHub Actions Errors

**Check workflow logs:**
- Go to: Actions → Latest workflow run → View logs

**Common Issues:**
- Missing secrets → Verify GitHub Secrets are set
- AWS credentials invalid → Regenerate and update secrets
- Terraform errors → Check Terraform configuration

## Cleanup (Destroy Infrastructure)

**⚠️ Warning: This will delete all resources!**

```bash
cd terraform
terraform destroy
```

Type `yes` when prompted, or use `-auto-approve` flag.

## Next Steps

1. **Monitor the pipeline:**
   - Set up CloudWatch alarms
   - Configure SNS notifications for errors

2. **Enhance functionality:**
   - Add data validation
   - Implement data transformation
   - Add more report types

3. **Optimize costs:**
   - Review CloudWatch log retention
   - Optimize Lambda memory allocation
   - Use S3 lifecycle policies

## Support

For issues or questions:
1. Check CloudWatch Logs
2. Review Terraform plan output
3. Verify IAM permissions
4. Check AWS Service Health Dashboard

