# How to View Lambda Functions in AWS

## Method 1: AWS Console (Web Interface) - Recommended

### Step-by-Step:

1. **Open AWS Console:**
   - Go to: https://040334732055.signin.aws.amazon.com/console
   - Sign in with username: `Assesment`

2. **Navigate to Lambda:**
   - In the top search bar, type: `Lambda`
   - Click on "Lambda" service

   **OR**

   - Go directly to: https://console.aws.amazon.com/lambda/home?region=us-east-1

3. **View Your Functions:**
   You should see two Lambda functions:
   - `event-driven-pipeline-process-data`
   - `event-driven-pipeline-daily-report`

4. **Click on a Function to View Details:**
   - **Configuration**: Runtime, memory, timeout, environment variables
   - **Code**: View the deployed code
   - **Test**: Test the function
   - **Monitor**: View metrics and logs
   - **Permissions**: View IAM roles and policies

---

## Method 2: AWS CLI (Command Line)

### List All Lambda Functions:
```powershell
aws lambda list-functions --region us-east-1
```

### Get Details of a Specific Function:
```powershell
# Process data function
aws lambda get-function --function-name event-driven-pipeline-process-data --region us-east-1

# Daily report function
aws lambda get-function --function-name event-driven-pipeline-daily-report --region us-east-1
```

### View Function Configuration:
```powershell
# Process data configuration
aws lambda get-function-configuration --function-name event-driven-pipeline-process-data --region us-east-1

# Daily report configuration
aws lambda get-function-configuration --function-name event-driven-pipeline-daily-report --region us-east-1
```

---

## What to Check in Each Lambda Function

### 1. process_data Function
**Location:** https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions/event-driven-pipeline-process-data

**Check:**
- ✅ **Configuration**: 
  - Runtime: Python 3.11
  - Handler: `process_data.lambda_handler`
  - Memory: 256 MB
  - Timeout: 60 seconds
- ✅ **Environment Variables**:
  - `REPORTS_BUCKET`: event-driven-pipeline-reports-dd6384b1
  - `RAW_BUCKET`: event-driven-pipeline-raw-data-dd6384b1
- ✅ **Triggers**: 
  - S3 bucket: `event-driven-pipeline-raw-data-dd6384b1`
  - Event: `s3:ObjectCreated:*`
- ✅ **Permissions**: 
  - IAM Role: `event-driven-pipeline-process-data-lambda-role`
- ✅ **Monitor Tab**: 
  - View invocations, errors, duration
  - View CloudWatch logs

### 2. daily_report Function
**Location:** https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions/event-driven-pipeline-daily-report

**Check:**
- ✅ **Configuration**: 
  - Runtime: Python 3.11
  - Handler: `daily_report.lambda_handler`
  - Memory: 512 MB
  - Timeout: 300 seconds
- ✅ **Environment Variables**:
  - `REPORTS_BUCKET`: event-driven-pipeline-reports-dd6384b1
- ✅ **Triggers**: 
  - EventBridge Rule: `event-driven-pipeline-daily-report-schedule`
  - Schedule: `cron(0 0 * * ? *)` (Daily at 00:00 UTC)
- ✅ **Permissions**: 
  - IAM Role: `event-driven-pipeline-daily-report-lambda-role`
- ✅ **Monitor Tab**: 
  - View invocations, errors, duration
  - View CloudWatch logs

---

## Quick Access Links

### Direct Links to Your Lambda Functions:

**Process Data Function:**
https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions/event-driven-pipeline-process-data

**Daily Report Function:**
https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions/event-driven-pipeline-daily-report

**All Lambda Functions:**
https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions

---

## Viewing Logs

### In AWS Console:
1. Go to Lambda function
2. Click **Monitor** tab
3. Click **View CloudWatch logs**
4. Click on a log stream to view logs

### Via AWS CLI:
```powershell
# Process data logs
aws logs tail /aws/lambda/event-driven-pipeline-process-data --follow --region us-east-1

# Daily report logs
aws logs tail /aws/lambda/event-driven-pipeline-daily-report --follow --region us-east-1
```

---

## Testing Lambda Functions

### Test process_data Function:
1. Go to Lambda function in console
2. Click **Test** tab
3. Create a test event (or use default)
4. Click **Test** button

### Test daily_report Function:
```powershell
aws lambda invoke \
  --function-name event-driven-pipeline-daily-report \
  --region us-east-1 \
  --payload '{}' \
  response.json

# View response
Get-Content response.json
```

---

## Monitoring Lambda Functions

### View Metrics:
1. Go to Lambda function
2. Click **Monitor** tab
3. View:
   - **Invocations**: Number of times function was called
   - **Duration**: Execution time
   - **Errors**: Error count
   - **Throttles**: If function was throttled
   - **Concurrent executions**: Current concurrent executions

### View Logs:
1. Click **Monitor** tab
2. Click **View CloudWatch logs**
3. Select a log stream
4. View real-time logs

---

## Troubleshooting

### If you don't see the functions:
1. Check you're in the correct region: **us-east-1**
2. Verify you're signed in to the correct AWS account
3. Check if filters are applied in the Lambda console

### If function shows errors:
1. Check **Monitor** tab for error details
2. View **CloudWatch Logs** for error messages
3. Check **Configuration** tab for environment variables
4. Verify **Permissions** are correct

---

## Summary

**Quick Access:**
- AWS Console: https://console.aws.amazon.com/lambda/home?region=us-east-1
- Search for: `event-driven-pipeline-process-data` or `event-driven-pipeline-daily-report`

**What to Check:**
- ✅ Functions are deployed
- ✅ Triggers are configured
- ✅ Environment variables are set
- ✅ Permissions are correct
- ✅ Logs are being generated

