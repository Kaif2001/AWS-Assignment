# ============================================
# GitHub Actions Setup Script
# ============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GitHub Actions CI/CD Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if git is initialized
if (-not (Test-Path .git)) {
    Write-Host "Initializing git repository..." -ForegroundColor Yellow
    git init
}

Write-Host ""
Write-Host "Step 1: Create GitHub Repository" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray
Write-Host "1. Go to: https://github.com/new" -ForegroundColor White
Write-Host "2. Repository name: event-driven-pipeline" -ForegroundColor White
Write-Host "3. Choose: Private (recommended)" -ForegroundColor White
Write-Host "4. DO NOT initialize with README" -ForegroundColor White
Write-Host "5. Click 'Create repository'" -ForegroundColor White
Write-Host ""
Write-Host "Press Enter after creating the repository..." -ForegroundColor Cyan
Read-Host

Write-Host ""
Write-Host "Step 2: Enter Your GitHub Details" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray
$githubUsername = Read-Host "Enter your GitHub username"
$repoName = Read-Host "Enter repository name (default: event-driven-pipeline)" 
if ([string]::IsNullOrWhiteSpace($repoName)) {
    $repoName = "event-driven-pipeline"
}

Write-Host ""
Write-Host "Step 3: Adding Remote Repository" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray

# Check if remote already exists
$remoteExists = git remote get-url origin 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Remote 'origin' already exists: $remoteExists" -ForegroundColor Yellow
    $update = Read-Host "Update it? (y/n)"
    if ($update -eq "y" -or $update -eq "Y") {
        git remote set-url origin "https://github.com/$githubUsername/$repoName.git"
        Write-Host "Remote updated!" -ForegroundColor Green
    }
} else {
    git remote add origin "https://github.com/$githubUsername/$repoName.git"
    Write-Host "Remote added!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 4: Renaming Branch to 'main'" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray
git branch -M main
Write-Host "Branch renamed to 'main'" -ForegroundColor Green

Write-Host ""
Write-Host "Step 5: Pushing Code to GitHub" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Gray
Write-Host "Pushing code..." -ForegroundColor Cyan
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Code Pushed Successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Step 6: Configure GitHub Secrets" -ForegroundColor Yellow
    Write-Host "----------------------------------------" -ForegroundColor Gray
    Write-Host "1. Go to: https://github.com/$githubUsername/$repoName/settings/secrets/actions" -ForegroundColor White
    Write-Host "2. Click 'New repository secret'" -ForegroundColor White
    Write-Host "3. Add these secrets:" -ForegroundColor White
    Write-Host ""
    Write-Host "   Secret 1:" -ForegroundColor Cyan
    Write-Host "   Name:  AWS_ACCESS_KEY_ID" -ForegroundColor White
    Write-Host "   Value: (Enter your AWS Access Key ID)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   Secret 2:" -ForegroundColor Cyan
    Write-Host "   Name:  AWS_SECRET_ACCESS_KEY" -ForegroundColor White
    Write-Host "   Value: (Enter your AWS Secret Access Key)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4. After adding secrets, the workflow will run automatically" -ForegroundColor White
    Write-Host "5. Check the 'Actions' tab to see the workflow running" -ForegroundColor White
    Write-Host ""
    Write-Host "Repository URL: https://github.com/$githubUsername/$repoName" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "Push failed. Please check:" -ForegroundColor Red
    Write-Host "1. Repository exists on GitHub" -ForegroundColor Yellow
    Write-Host "2. You have push permissions" -ForegroundColor Yellow
    Write-Host "3. GitHub credentials are correct" -ForegroundColor Yellow
}

Write-Host ""

