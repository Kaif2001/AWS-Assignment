# ============================================
# Dependency Check Script
# Event-Driven Data Processing Pipeline
# ============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Checking Dependencies and Tools" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allChecksPassed = $true

# ============================================
# 1. Check Terraform
# ============================================
Write-Host "[1/5] Checking Terraform..." -ForegroundColor Yellow
$terraformInstalled = $false
try {
    $terraformOutput = terraform version 2>&1
    if ($LASTEXITCODE -eq 0 -or $terraformOutput -match "Terraform") {
        $terraformInstalled = $true
        $versionMatch = $terraformOutput | Select-String -Pattern "Terraform v(\d+\.\d+\.\d+)" 
        if ($versionMatch) {
            $version = $versionMatch.Matches.Groups[1].Value
            Write-Host "  [OK] Terraform is installed" -ForegroundColor Green
            Write-Host "       Version: $version" -ForegroundColor Gray
            
            # Check if version is >= 1.0
            $majorVersion = [int]($version.Split('.')[0])
            if ($majorVersion -ge 1) {
                Write-Host "       Version is compatible (>= 1.0)" -ForegroundColor Green
            } else {
                Write-Host "       WARNING: Version is too old (need >= 1.0)" -ForegroundColor Red
                $allChecksPassed = $false
            }
        } else {
            Write-Host "  [OK] Terraform is installed" -ForegroundColor Green
        }
    }
} catch {
    $terraformInstalled = $false
}

if (-not $terraformInstalled) {
    Write-Host "  [FAIL] Terraform is NOT installed" -ForegroundColor Red
    Write-Host "         Download from: https://www.terraform.io/downloads" -ForegroundColor Gray
    $allChecksPassed = $false
}
Write-Host ""

# ============================================
# 2. Check Git
# ============================================
Write-Host "[2/5] Checking Git..." -ForegroundColor Yellow
$gitInstalled = $false
try {
    $gitOutput = git --version 2>&1
    if ($LASTEXITCODE -eq 0 -or $gitOutput -match "git version") {
        $gitInstalled = $true
        Write-Host "  [OK] Git is installed" -ForegroundColor Green
        Write-Host "       $gitOutput" -ForegroundColor Gray
    }
} catch {
    $gitInstalled = $false
}

if (-not $gitInstalled) {
    Write-Host "  [FAIL] Git is NOT installed" -ForegroundColor Red
    Write-Host "         Download from: https://git-scm.com/download/win" -ForegroundColor Gray
    $allChecksPassed = $false
}
Write-Host ""

# ============================================
# 3. Check AWS CLI (Optional)
# ============================================
Write-Host "[3/5] Checking AWS CLI (Optional)..." -ForegroundColor Yellow
$awsInstalled = $false
try {
    $awsOutput = aws --version 2>&1
    if ($LASTEXITCODE -eq 0 -or $awsOutput -match "aws-cli") {
        $awsInstalled = $true
        Write-Host "  [OK] AWS CLI is installed" -ForegroundColor Green
        Write-Host "       $awsOutput" -ForegroundColor Gray
        
        # Check AWS credentials
        Write-Host "       Checking AWS credentials..." -ForegroundColor Gray
        try {
            $awsIdentityOutput = aws sts get-caller-identity 2>&1
            if ($LASTEXITCODE -eq 0) {
                $identityJson = $awsIdentityOutput | ConvertFrom-Json
                $accountId = $identityJson.Account
                $userId = $identityJson.Arn
                Write-Host "       [OK] AWS credentials are configured" -ForegroundColor Green
                Write-Host "            Account ID: $accountId" -ForegroundColor Gray
                Write-Host "            User/Role: $userId" -ForegroundColor Gray
            } else {
                Write-Host "       [WARN] AWS credentials are NOT configured" -ForegroundColor Yellow
                Write-Host "              Run: aws configure" -ForegroundColor Gray
            }
        } catch {
            Write-Host "       [WARN] AWS credentials are NOT configured" -ForegroundColor Yellow
            Write-Host "              Run: aws configure" -ForegroundColor Gray
        }
    }
} catch {
    $awsInstalled = $false
}

if (-not $awsInstalled) {
    Write-Host "  [WARN] AWS CLI is NOT installed (Optional)" -ForegroundColor Yellow
    Write-Host "         Download from: https://aws.amazon.com/cli/" -ForegroundColor Gray
    Write-Host "         Note: Not required for deployment, but useful for testing" -ForegroundColor Gray
}
Write-Host ""

# ============================================
# 4. Check Python (Optional)
# ============================================
Write-Host "[4/5] Checking Python (Optional)..." -ForegroundColor Yellow
$pythonInstalled = $false
try {
    $pythonOutput = python --version 2>&1
    if ($LASTEXITCODE -eq 0 -or $pythonOutput -match "Python") {
        $pythonInstalled = $true
        Write-Host "  [OK] Python is installed" -ForegroundColor Green
        Write-Host "       $pythonOutput" -ForegroundColor Gray
        
        # Check Python version
        if ($pythonOutput -match "Python (\d+)\.(\d+)") {
            $major = [int]$matches[1]
            $minor = [int]$matches[2]
            if ($major -eq 3 -and $minor -ge 9) {
                Write-Host "       Version is compatible (3.9+)" -ForegroundColor Green
            } else {
                Write-Host "       WARNING: Version may be outdated (recommended: 3.11)" -ForegroundColor Yellow
            }
        }
        
        # Check if boto3 is installed (for local testing)
        try {
            $boto3Check = python -c "import boto3" 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "       boto3 is installed (for local testing)" -ForegroundColor Green
            } else {
                Write-Host "       WARNING: boto3 is NOT installed (optional)" -ForegroundColor Yellow
                Write-Host "                Install with: pip install boto3" -ForegroundColor Gray
            }
        } catch {
            Write-Host "       WARNING: boto3 is NOT installed (optional)" -ForegroundColor Yellow
        }
    }
} catch {
    $pythonInstalled = $false
}

if (-not $pythonInstalled) {
    Write-Host "  [WARN] Python is NOT installed (Optional)" -ForegroundColor Yellow
    Write-Host "         Download from: https://www.python.org/downloads/" -ForegroundColor Gray
    Write-Host "         Note: Not required for deployment, Lambda uses AWS runtime" -ForegroundColor Gray
}
Write-Host ""

# ============================================
# 5. Check Project Files
# ============================================
Write-Host "[5/5] Checking Project Files..." -ForegroundColor Yellow
$requiredFiles = @(
    "terraform\main.tf",
    "terraform\variables.tf",
    "terraform\outputs.tf",
    "lambda\process_data.py",
    "lambda\daily_report.py",
    ".github\workflows\deploy.yml",
    "README.md"
)

$missingFiles = @()
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  [OK] $file" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $file (MISSING)" -ForegroundColor Red
        $missingFiles += $file
        $allChecksPassed = $false
    }
}

if ($missingFiles.Count -eq 0) {
    Write-Host "  All project files are present" -ForegroundColor Green
} else {
    Write-Host "  Some project files are missing" -ForegroundColor Red
}
Write-Host ""

# ============================================
# Summary
# ============================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($allChecksPassed) {
    Write-Host "[SUCCESS] All REQUIRED dependencies are installed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Configure AWS credentials (if not done): aws configure" -ForegroundColor White
    Write-Host "2. Navigate to terraform directory: cd terraform" -ForegroundColor White
    Write-Host "3. Initialize Terraform: terraform init" -ForegroundColor White
    Write-Host "4. Review deployment plan: terraform plan" -ForegroundColor White
    Write-Host "5. Deploy infrastructure: terraform apply" -ForegroundColor White
} else {
    Write-Host "[WARNING] Some REQUIRED dependencies are missing!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install the missing tools:" -ForegroundColor Yellow
    Write-Host "- Terraform: https://www.terraform.io/downloads" -ForegroundColor White
    Write-Host "- Git: https://git-scm.com/download/win" -ForegroundColor White
    Write-Host ""
    Write-Host "Optional tools (recommended):" -ForegroundColor Yellow
    Write-Host "- AWS CLI: https://aws.amazon.com/cli/" -ForegroundColor White
    Write-Host "- Python: https://www.python.org/downloads/" -ForegroundColor White
}

Write-Host ""
Write-Host "For detailed information, see REQUIREMENTS.md" -ForegroundColor Gray
Write-Host ""
