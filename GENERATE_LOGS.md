# How to Generate and View CloudWatch Logs

## Why No Logs Appear

The log groups exist, but there are **no log streams yet** because the Lambda functions haven't been invoked. The `--follow` flag waits for new logs, so it appears to hang when there are no logs.

## Solution: Trigger the Functions to Generate Logs

### Option 1: Test process_data Function (Upload File to S3)

This will automatically trigger the Lambda and create logs:

```powershell
# Create a test CSV file
@"
name,age,city
John,30,New York
Jane,25,Los Angeles
Bob,35,Chicago
Alice,28,Seattle
"@ | Out-File -FilePath test-data.csv -Encoding utf8

# Upload to S3 (this triggers the Lambda automatically)
aws s3 cp test-data.csv s3://event-driven-pipeline-raw-data-dd6384b1/

# Wait 5-10 seconds, then check logs
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 --since 5m
```

### Option 2: Manually Invoke Lambda Functions

#### Invoke process_data Function:
```powershell
# Create a test event (simulating S3 upload)
$testEvent = @{
    Records = @(
        @{
            eventSource = "aws:s3"
            s3 = @{
                bucket = @{ name = "event-driven-pipeline-raw-data-dd6384b1" }
                object = @{ key = "test-file.csv" }
            }
        }
    )
} | ConvertTo-Json -Depth 10

# Invoke the function
aws lambda invoke `
  --function-name event-driven-pipeline-process-data `
  --region us-east-1 `
  --payload $testEvent `
  response.json

# View response
Get-Content response.json
```

#### Invoke daily_report Function:
```powershell
# Invoke daily report function
aws lambda invoke `
  --function-name event-driven-pipeline-daily-report `
  --region us-east-1 `
  --payload '{}' `
  response.json

# View response
Get-Content response.json
```

---

## After Triggering: View Logs

### View Logs Without --follow (Shows Existing Logs):
```powershell
# View recent logs (last 5 minutes)
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 --since 5m

# View logs from last hour
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 --since 1h

# View last 50 log events
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 -n 50
```

### View Logs With --follow (Real-Time):
```powershell
# This will show existing logs, then wait for new ones
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 --follow

# Press Ctrl+C to stop
```

---

## Complete Test Workflow

### Step 1: Upload Test File
```powershell
# Create test file
@"
name,age,city
John,30,New York
Jane,25,Los Angeles
"@ | Out-File -FilePath test.csv -Encoding utf8

# Upload to S3
aws s3 cp test.csv s3://event-driven-pipeline-raw-data-dd6384b1/
```

### Step 2: Wait a Few Seconds
```powershell
# Wait 5 seconds for Lambda to process
Start-Sleep -Seconds 5
```

### Step 3: View Logs
```powershell
# View logs (without --follow first to see what exists)
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 --since 5m

# Or with follow to see real-time updates
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 --follow
```

### Step 4: Check Processed File
```powershell
# Verify processed file was created
aws s3 ls s3://event-driven-pipeline-reports-dd6384b1/processed/
```

---

## Alternative: Check Log Streams First

Before using `--follow`, check if log streams exist:

```powershell
# Check if log streams exist for process_data
aws logs describe-log-streams `
  --log-group-name "/aws/lambda/event-driven-pipeline-process-data" `
  --region us-east-1 `
  --order-by LastEventTime `
  --descending `
  --max-items 5

# If empty, trigger the function first
```

---

## Quick Commands Reference

### Generate Logs:
```powershell
# Upload file to trigger process_data
aws s3 cp test.csv s3://event-driven-pipeline-raw-data-dd6384b1/

# Invoke daily_report manually
aws lambda invoke --function-name event-driven-pipeline-daily-report --region us-east-1 --payload '{}' response.json
```

### View Logs (Without Waiting):
```powershell
# Last 5 minutes
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 --since 5m

# Last hour
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 --since 1h

# Last 50 events
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 -n 50
```

### View Logs (With Follow):
```powershell
# Real-time (after logs exist)
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 --follow
```

---

## Troubleshooting

### If `--follow` shows nothing:
1. **No logs exist yet** - Trigger the function first
2. **Wait a few seconds** - CloudWatch has a slight delay
3. **Check region** - Make sure you're using `us-east-1`

### If logs still don't appear:
1. Check Lambda function was invoked successfully
2. Verify IAM permissions for CloudWatch Logs
3. Check function execution didn't fail immediately

---

## Expected Log Output

Once logs are generated, you should see:

```
START RequestId: abc-123-xyz Version: $LATEST
Received event: {...}
Processing file: s3://bucket/file.csv
File metadata retrieved: {...}
Processing complete. Records found: 3
Successfully processed: file.csv
END RequestId: abc-123-xyz
REPORT RequestId: abc-123-xyz Duration: 1234.56 ms Billed Duration: 1235 ms Memory Size: 256 MB Max Memory Used: 89 MB
```

