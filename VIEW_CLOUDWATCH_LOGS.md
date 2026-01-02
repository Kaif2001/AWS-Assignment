# How to View CloudWatch Logs for Lambda Functions

## Method 1: AWS Console (Web Interface) - Recommended

### Step-by-Step:

1. **Open AWS Console:**
   - Go to: https://040334732055.signin.aws.amazon.com/console
   - Sign in with username: `Assesment`

2. **Navigate to CloudWatch:**
   - In the top search bar, type: `CloudWatch`
   - Click on "CloudWatch" service

   **OR**

   - Go directly to: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1

3. **View Log Groups:**
   - In the left sidebar, click **"Logs"** → **"Log groups"**
   - You should see two log groups:
     - `/aws/lambda/event-driven-pipeline-process-data`
     - `/aws/lambda/event-driven-pipeline-daily-report`

4. **View Logs:**
   - Click on a log group name
   - Click on a log stream (most recent one)
   - View the logs in real-time

---

## Method 2: AWS CLI (Command Line)

### List All Log Groups:
```powershell
aws logs describe-log-groups --region us-east-1 --log-group-name-prefix "/aws/lambda/event-driven-pipeline"
```

### View Recent Logs for process_data:
```powershell
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 --follow
```

### View Recent Logs for daily_report:
```powershell
aws logs tail /aws/lambda/event-driven-pipeline-daily-report --region us-east-1 --follow
```

### View Logs from Last Hour:
```powershell
# Process data logs
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 --since 1h

# Daily report logs
aws logs tail /aws/lambda/event-driven-pipeline-daily-report --region us-east-1 --since 1h
```

### View Logs from Specific Time:
```powershell
# View logs from last 24 hours
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 --since 24h

# View logs from a specific date
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 --since "2026-01-02T00:00:00"
```

### View Last N Log Events:
```powershell
# Last 50 log events
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 --format short -n 50
```

---

## Direct Links to Log Groups

### Process Data Logs:
https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups/log-group/$252Faws$252Flambda$252Fevent-driven-pipeline-process-data

### Daily Report Logs:
https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups/log-group/$252Faws$252Flambda$252Fevent-driven-pipeline-daily-report

### All Log Groups:
https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups

---

## Viewing Logs from Lambda Console

### Alternative Method:

1. **Go to Lambda Function:**
   - https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions/event-driven-pipeline-process-data

2. **Click "Monitor" Tab:**
   - Scroll down to "CloudWatch Logs"
   - Click "View CloudWatch logs"

3. **View Log Streams:**
   - Click on the most recent log stream
   - View logs in real-time

---

## Useful AWS CLI Commands

### Get Log Streams:
```powershell
# List log streams for process_data
aws logs describe-log-streams --log-group-name "/aws/lambda/event-driven-pipeline-process-data" --region us-east-1 --order-by LastEventTime --descending --max-items 5

# List log streams for daily_report
aws logs describe-log-streams --log-group-name "/aws/lambda/event-driven-pipeline-daily-report" --region us-east-1 --order-by LastEventTime --descending --max-items 5
```

### Get Specific Log Events:
```powershell
# Get log events from a specific stream
aws logs get-log-events --log-group-name "/aws/lambda/event-driven-pipeline-process-data" --log-stream-name "STREAM_NAME" --region us-east-1
```

### Filter Logs:
```powershell
# Filter logs for errors only
aws logs filter-log-events --log-group-name "/aws/lambda/event-driven-pipeline-process-data" --filter-pattern "ERROR" --region us-east-1

# Filter logs for specific text
aws logs filter-log-events --log-group-name "/aws/lambda/event-driven-pipeline-process-data" --filter-pattern "Processing file" --region us-east-1
```

### Export Logs:
```powershell
# Export logs to a file
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 --since 24h > lambda-logs.txt
```

---

## Log Group Details

### process_data Log Group:
- **Name**: `/aws/lambda/event-driven-pipeline-process-data`
- **Retention**: 7 days
- **Purpose**: Logs all file processing activities
- **Contains**: 
  - File upload events
  - Processing results
  - Error messages
  - Record counts

### daily_report Log Group:
- **Name**: `/aws/lambda/event-driven-pipeline-daily-report`
- **Retention**: 30 days
- **Purpose**: Logs daily report generation
- **Contains**:
  - Report generation events
  - Summary statistics
  - Error messages
  - File scanning results

---

## What to Look For in Logs

### Successful Processing:
```
START RequestId: xxx
Processing file: s3://bucket/file.csv
File metadata retrieved: {...}
Processing complete. Records found: 10
Successfully processed: file.csv
END RequestId: xxx
```

### Errors:
```
ERROR: Error processing file: <error message>
ERROR: Error saving processed data: <error message>
```

### Daily Report:
```
Daily report generation started at 2026-01-02T00:00:00
Generating report for date: 2026-01-01
Total processed files collected: 5
Summary generated: 5 files, 150 records
Daily report saved successfully: daily-reports/2026-01-01_daily_summary.json
```

---

## Real-Time Monitoring

### Follow Logs in Real-Time (CLI):
```powershell
# Watch process_data logs live
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 --follow

# Watch daily_report logs live
aws logs tail /aws/lambda/event-driven-pipeline-daily-report --region us-east-1 --follow
```

### In AWS Console:
1. Go to CloudWatch Logs
2. Click on log group
3. Click on log stream
4. Click "Live tail" button (if available) or refresh to see new logs

---

## CloudWatch Metrics

### View Lambda Metrics:
1. Go to: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#metricsV2
2. Search for: `AWS/Lambda`
3. Select your function name
4. View metrics:
   - **Invocations**: Number of function calls
   - **Errors**: Error count
   - **Duration**: Execution time
   - **Throttles**: If function was throttled

### Direct Links to Metrics:
- **Process Data Metrics**: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#metricsV2:graph=~();namespace=~'AWS/Lambda';dimensions=~'FunctionName~event-driven-pipeline-process-data'
- **Daily Report Metrics**: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#metricsV2:graph=~();namespace=~'AWS/Lambda';dimensions=~'FunctionName~event-driven-pipeline-daily-report'

---

## Troubleshooting

### If logs don't appear:
1. Check you're in the correct region: **us-east-1**
2. Verify the Lambda function was invoked
3. Check log group retention settings
4. Wait a few seconds for logs to appear (CloudWatch has slight delay)

### If you see "No log streams":
1. The function hasn't been invoked yet
2. Test the function to generate logs
3. Upload a file to trigger process_data
4. Wait for EventBridge to trigger daily_report (or trigger manually)

### If logs are empty:
1. Check Lambda function permissions
2. Verify CloudWatch Logs permissions
3. Check if function execution succeeded

---

## Quick Reference Commands

```powershell
# View all log groups
aws logs describe-log-groups --region us-east-1

# Follow process_data logs
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 --follow

# Follow daily_report logs
aws logs tail /aws/lambda/event-driven-pipeline-daily-report --region us-east-1 --follow

# View last 100 log events
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 -n 100

# Filter for errors
aws logs filter-log-events --log-group-name "/aws/lambda/event-driven-pipeline-process-data" --filter-pattern "ERROR" --region us-east-1

# Export logs to file
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 --since 24h > logs.txt
```

---

## Summary

**Quick Access:**
- CloudWatch Logs: https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups
- Process Data Logs: Direct link above
- Daily Report Logs: Direct link above

**CLI Commands:**
- `aws logs tail` - View logs
- `aws logs describe-log-streams` - List log streams
- `aws logs filter-log-events` - Filter logs

**What to Check:**
- ✅ Log groups exist
- ✅ Log streams are being created
- ✅ Logs contain expected information
- ✅ No errors in logs
- ✅ Metrics show function invocations

