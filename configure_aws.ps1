# ============================================
# AWS Configuration Helper Script
# ============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AWS Configuration Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will help you configure AWS CLI credentials." -ForegroundColor Yellow
Write-Host ""
Write-Host "You will need:" -ForegroundColor Yellow
Write-Host "1. AWS Access Key ID" -ForegroundColor White
Write-Host "2. AWS Secret Access Key" -ForegroundColor White
Write-Host "3. Default region (e.g., us-east-1)" -ForegroundColor White
Write-Host "4. Default output format (json, yaml, text, table)" -ForegroundColor White
Write-Host ""
Write-Host "To get your AWS credentials:" -ForegroundColor Yellow
Write-Host "1. Log in to AWS Console: https://console.aws.amazon.com/" -ForegroundColor White
Write-Host "2. Go to: IAM -> Users -> Your User -> Security Credentials" -ForegroundColor White
Write-Host "3. Click 'Create Access Key'" -ForegroundColor White
Write-Host "4. Copy the Access Key ID and Secret Access Key" -ForegroundColor White
Write-Host ""
Write-Host "Press Enter to start configuration, or Ctrl+C to cancel..." -ForegroundColor Cyan
Read-Host

# Run aws configure
aws configure

Write-Host ""
Write-Host "Testing AWS credentials..." -ForegroundColor Yellow
try {
    $identity = aws sts get-caller-identity 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[SUCCESS] AWS credentials are configured correctly!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Your AWS Account Information:" -ForegroundColor Cyan
        $identityJson = $identity | ConvertFrom-Json
        Write-Host "  Account ID: $($identityJson.Account)" -ForegroundColor White
        Write-Host "  User/Role ARN: $($identityJson.Arn)" -ForegroundColor White
        Write-Host "  User ID: $($identityJson.UserId)" -ForegroundColor White
    } else {
        Write-Host "[ERROR] AWS credentials are not valid. Please check your credentials." -ForegroundColor Red
    }
} catch {
    Write-Host "[ERROR] Failed to verify AWS credentials." -ForegroundColor Red
}

Write-Host ""

