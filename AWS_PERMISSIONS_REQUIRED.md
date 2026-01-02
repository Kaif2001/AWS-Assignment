# AWS Permissions Required for Deployment

## Issue
The AWS user `Assesment` is missing required permissions to deploy the infrastructure.

## Required Permissions

The user needs the following AWS permissions:

### 1. S3 Permissions
- `s3:CreateBucket` - To create S3 buckets
- `s3:PutBucketVersioning` - To enable versioning
- `s3:PutBucketPublicAccessBlock` - To block public access
- `s3:PutBucketNotification` - To configure S3 event notifications
- `s3:GetBucketLocation` - To get bucket information
- `s3:ListBucket` - To list bucket contents
- `s3:PutObject` - To upload objects
- `s3:GetObject` - To read objects
- `s3:DeleteObject` - To delete objects

### 2. IAM Permissions
- `iam:CreateRole` - To create IAM roles for Lambda
- `iam:AttachRolePolicy` - To attach policies to roles
- `iam:PutRolePolicy` - To create inline policies
- `iam:GetRole` - To get role information
- `iam:PassRole` - To pass roles to Lambda functions
- `iam:ListRoles` - To list roles

### 3. Lambda Permissions
- `lambda:CreateFunction` - To create Lambda functions
- `lambda:AddPermission` - To add permissions for triggers
- `lambda:GetFunction` - To get function information
- `lambda:UpdateFunctionConfiguration` - To update function settings
- `lambda:PutFunctionEventInvokeConfig` - To configure function settings

### 4. EventBridge (CloudWatch Events) Permissions
- `events:PutRule` - To create scheduled rules
- `events:PutTargets` - To add targets to rules
- `events:TagResource` - To tag EventBridge resources
- `events:DescribeRule` - To describe rules

### 5. CloudWatch Logs Permissions
- `logs:CreateLogGroup` - To create log groups
- `logs:PutRetentionPolicy` - To set log retention
- `logs:DescribeLogGroups` - To describe log groups

## Solution Options

### Option 1: Attach Administrator Access (Recommended for Learning/Testing)

If this is a learning/testing environment, you can attach the `AdministratorAccess` policy:

1. Log in to AWS Console: https://040334732055.signin.aws.amazon.com/console
2. Go to **IAM** → **Users** → **Assesment**
3. Click **Add permissions** → **Attach policies directly**
4. Search for and select: **AdministratorAccess**
5. Click **Next** → **Add permissions**

**Note:** AdministratorAccess grants full access. Use only in development/testing environments.

### Option 2: Create Custom Policy (Recommended for Production)

Create a custom policy with only the required permissions:

1. Go to **IAM** → **Policies** → **Create policy**
2. Click **JSON** tab
3. Paste the policy below
4. Name it: `EventDrivenPipelineDeploymentPolicy`
5. Attach it to the `Assesment` user

### Option 3: Request Permissions from Administrator

If you don't have permission to modify IAM policies, contact your AWS administrator and request the permissions listed above.

## Custom Policy JSON

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateRole",
                "iam:AttachRolePolicy",
                "iam:PutRolePolicy",
                "iam:GetRole",
                "iam:PassRole",
                "iam:ListRoles",
                "iam:GetRolePolicy",
                "iam:DeleteRole",
                "iam:DeleteRolePolicy",
                "iam:DetachRolePolicy"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "lambda:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "events:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:*"
            ],
            "Resource": "*"
        }
    ]
}
```

## Step-by-Step: Attach AdministratorAccess (Quick Fix)

1. **Open AWS Console**: https://040334732055.signin.aws.amazon.com/console
2. **Navigate to IAM**:
   - Search for "IAM" in the top search bar
   - Click on "IAM"
3. **Go to Users**:
   - Click "Users" in the left sidebar
   - Click on "Assesment"
4. **Add Permissions**:
   - Click "Add permissions" button
   - Select "Attach policies directly"
   - Search for "AdministratorAccess"
   - Check the box next to "AdministratorAccess"
   - Click "Next"
   - Click "Add permissions"
5. **Verify**:
   - You should see "AdministratorAccess" in the user's permissions list

## After Adding Permissions

Once permissions are added, you can retry the deployment:

```powershell
cd terraform
terraform apply
```

Type `yes` when prompted.

## Troubleshooting

### If you still get permission errors:
1. Wait 1-2 minutes for permissions to propagate
2. Verify the policy is attached to the user
3. Check that you're using the correct AWS account
4. Try logging out and back into AWS Console

### If you can't modify IAM:
- Contact your AWS administrator
- Provide them with this document
- Request the permissions listed above

## Security Note

- **AdministratorAccess** should only be used in development/testing
- For production, use the custom policy with minimal required permissions
- Always follow the principle of least privilege

