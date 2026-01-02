# ============================================
# Test Pipeline Script
# Generates logs by triggering Lambda functions
# ============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing Event-Driven Pipeline" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Create test file
Write-Host "[1/3] Creating test file..." -ForegroundColor Yellow
@"
name,age,city
John,30,New York
Jane,25,Los Angeles
Bob,35,Chicago
Alice,28,Seattle
"@ | Out-File -FilePath test-data.csv -Encoding utf8

Write-Host "  Test file created: test-data.csv" -ForegroundColor Green
Write-Host ""

# Step 2: Upload to S3 (triggers process_data Lambda)
Write-Host "[2/3] Uploading file to S3 (this triggers process_data Lambda)..." -ForegroundColor Yellow
aws s3 cp test-data.csv s3://event-driven-pipeline-raw-data-dd6384b1/ --region us-east-1

if ($LASTEXITCODE -eq 0) {
    Write-Host "  File uploaded successfully" -ForegroundColor Green
    Write-Host "  Lambda function should be processing now..." -ForegroundColor Green
} else {
    Write-Host "  Upload failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[3/3] Waiting 10 seconds for Lambda to process..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Viewing Logs" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Recent logs from process_data function:" -ForegroundColor Yellow
Write-Host ""

# Step 3: View logs
aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 --since 2m

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Checking Processed Files" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Files in reports bucket:" -ForegroundColor Yellow
aws s3 ls s3://event-driven-pipeline-reports-dd6384b1/processed/ --region us-east-1

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Test Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "To view logs in real-time, use:" -ForegroundColor Cyan
Write-Host 'aws logs tail /aws/lambda/event-driven-pipeline-process-data --region us-east-1 --follow' -ForegroundColor White
Write-Host ""
