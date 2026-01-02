# Dependencies and Tools Required

This document lists all the dependencies, tools, and prerequisites needed to deploy and run the Event-Driven Data Processing Pipeline.

---

## 📋 Prerequisites Overview

### Essential Requirements (Must Have)
1. **AWS Account** with appropriate permissions
2. **Terraform** (version >= 1.0)
3. **Git** (for version control)
4. **GitHub Account** (for CI/CD)

### Optional but Recommended
5. **AWS CLI** (for testing and manual operations)
6. **Python 3.11** (for local testing of Lambda functions)
7. **Text Editor/IDE** (VS Code, PyCharm, etc.)

---

## 🔧 Detailed Requirements

### 1. AWS Account

**What it is:** Amazon Web Services account to host the infrastructure

**How to get it:**
- Sign up at: https://aws.amazon.com/
- Free tier available for 12 months

**Required Permissions:**
Your AWS user/role needs permissions for:
- S3 (create buckets, manage objects)
- Lambda (create functions, manage triggers)
- IAM (create roles and policies)
- EventBridge (create rules and targets)
- CloudWatch (create log groups)
- Terraform state management (if using S3 backend)

**Minimum IAM Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "lambda:*",
        "iam:*",
        "events:*",
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
```

**Cost:** Free tier available, then pay-as-you-go (~$5-10/month for moderate usage)

---

### 2. Terraform

**What it is:** Infrastructure as Code tool to deploy AWS resources

**Version Required:** >= 1.0 (project uses 1.6.0 in CI/CD)

**Installation:**

**Windows:**
```powershell
# Using Chocolatey
choco install terraform

# Or download from: https://www.terraform.io/downloads
```

**macOS:**
```bash
# Using Homebrew
brew install terraform
```

**Linux:**
```bash
# Download and install
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

**Verify Installation:**
```bash
terraform version
# Should output: Terraform v1.6.0 (or higher)
```

**Terraform Providers (Auto-downloaded):**
- `hashicorp/aws` (~> 5.0) - AWS resources
- `hashicorp/random` (~> 3.0) - Random IDs for bucket names
- `hashicorp/archive` (~> 2.0) - Zip files for Lambda deployment

**Note:** Providers are automatically downloaded when you run `terraform init`

---

### 3. Git

**What it is:** Version control system

**Version Required:** Any recent version

**Installation:**

**Windows:**
- Download from: https://git-scm.com/download/win
- Or use: `winget install Git.Git`

**macOS:**
```bash
# Usually pre-installed, or:
brew install git
```

**Linux:**
```bash
sudo apt-get install git  # Ubuntu/Debian
sudo yum install git      # CentOS/RHEL
```

**Verify Installation:**
```bash
git --version
```

---

### 4. GitHub Account

**What it is:** Code repository and CI/CD platform

**How to get it:**
- Sign up at: https://github.com/
- Free account is sufficient

**Required Setup:**
1. Create a new repository
2. Set up GitHub Secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

**How to set GitHub Secrets:**
1. Go to: Repository → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add each secret with its value

---

### 5. AWS CLI (Optional but Recommended)

**What it is:** Command-line interface for AWS services

**Version Required:** AWS CLI v2 recommended

**Installation:**

**Windows:**
```powershell
# Using MSI installer
# Download from: https://aws.amazon.com/cli/
```

**macOS:**
```bash
brew install awscli
```

**Linux:**
```bash
# Download AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Configuration:**
```bash
aws configure
# Enter:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (e.g., us-east-1)
# - Default output format (json)
```

**Verify Installation:**
```bash
aws --version
aws sts get-caller-identity  # Test credentials
```

**Use Cases:**
- Testing the pipeline
- Uploading test files to S3
- Viewing CloudWatch logs
- Manual Lambda invocations

---

### 6. Python 3.11 (Optional - for Local Testing)

**What it is:** Programming language for Lambda functions

**Version Required:** Python 3.11 (matches Lambda runtime)

**Installation:**

**Windows:**
- Download from: https://www.python.org/downloads/
- Or use: `winget install Python.Python.3.11`

**macOS:**
```bash
brew install python@3.11
```

**Linux:**
```bash
sudo apt-get install python3.11 python3.11-pip
```

**Verify Installation:**
```bash
python3 --version
# Should output: Python 3.11.x
```

**Python Dependencies (for Local Testing):**
The Lambda functions use only **standard library** modules:
- `json` (built-in)
- `boto3` (AWS SDK - provided by Lambda runtime)
- `os` (built-in)
- `datetime` (built-in)
- `typing` (built-in)
- `collections` (built-in)

**Note:** For local testing, you may want to install `boto3`:
```bash
pip install boto3
```

**Lambda Runtime:**
- AWS Lambda provides Python 3.11 runtime automatically
- No need to package `boto3` - it's included in the runtime

---

### 7. Text Editor/IDE (Optional but Recommended)

**Recommended Options:**
- **VS Code** with extensions:
  - HashiCorp Terraform
  - Python
  - AWS Toolkit
- **PyCharm** (for Python development)
- **Sublime Text** or **Atom** (lightweight)

---

## 📦 Installation Checklist

Use this checklist to ensure you have everything installed:

### Required Tools
- [ ] AWS Account created and configured
- [ ] Terraform installed (version >= 1.0)
- [ ] Git installed
- [ ] GitHub account created

### Optional Tools
- [ ] AWS CLI installed and configured
- [ ] Python 3.11 installed (for local testing)
- [ ] Text editor/IDE installed

### AWS Configuration
- [ ] AWS Access Key ID obtained
- [ ] AWS Secret Access Key obtained
- [ ] AWS region selected (default: us-east-1)
- [ ] IAM permissions verified

### GitHub Configuration
- [ ] GitHub repository created
- [ ] GitHub Secrets configured:
  - [ ] `AWS_ACCESS_KEY_ID`
  - [ ] `AWS_SECRET_ACCESS_KEY`

---

## 🚀 Quick Setup Commands

### Windows (PowerShell)
```powershell
# Install Terraform (if using Chocolatey)
choco install terraform

# Install AWS CLI (download MSI from AWS website)
# Install Git (download from git-scm.com)

# Verify installations
terraform version
git --version
aws --version
```

### macOS
```bash
# Install using Homebrew
brew install terraform awscli git python@3.11

# Verify installations
terraform version
git --version
aws --version
python3 --version
```

### Linux (Ubuntu/Debian)
```bash
# Update package list
sudo apt-get update

# Install tools
sudo apt-get install -y terraform awscli git python3.11 python3-pip

# Verify installations
terraform version
git --version
aws --version
python3 --version
```

---

## 🔍 Verification Steps

After installation, verify everything works:

### 1. Verify Terraform
```bash
terraform version
# Expected: Terraform v1.6.0 (or higher)
```

### 2. Verify AWS CLI
```bash
aws --version
# Expected: aws-cli/2.x.x

aws sts get-caller-identity
# Should return your AWS account details
```

### 3. Verify Git
```bash
git --version
# Expected: git version 2.x.x
```

### 4. Verify Python (if installed)
```bash
python3 --version
# Expected: Python 3.11.x
```

### 5. Test Terraform with AWS
```bash
cd terraform
terraform init
# Should download AWS provider successfully
```

---

## 💡 Troubleshooting

### Issue: Terraform not found
**Solution:** Add Terraform to your system PATH

### Issue: AWS credentials not working
**Solution:** 
- Run `aws configure` again
- Check IAM permissions
- Verify access keys are correct

### Issue: GitHub Actions failing
**Solution:**
- Verify GitHub Secrets are set correctly
- Check AWS credentials have sufficient permissions
- Review workflow logs in GitHub Actions tab

### Issue: Python version mismatch
**Solution:**
- Lambda uses Python 3.11 runtime (handled by AWS)
- Local Python version doesn't need to match exactly
- For local testing, Python 3.9+ should work

---

## 📚 Additional Resources

- **Terraform Documentation:** https://www.terraform.io/docs
- **AWS Documentation:** https://docs.aws.amazon.com/
- **GitHub Actions:** https://docs.github.com/en/actions
- **AWS CLI Documentation:** https://docs.aws.amazon.com/cli/
- **Python Documentation:** https://docs.python.org/3/

---

## ✅ Summary

**Minimum Requirements:**
1. AWS Account
2. Terraform (>= 1.0)
3. Git
4. GitHub Account

**Recommended Additions:**
5. AWS CLI
6. Python 3.11 (for testing)
7. Code Editor/IDE

**Total Setup Time:** ~30-60 minutes (depending on download speeds)

---

**Last Updated:** 2024

