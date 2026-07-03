# Creating IAM Policy to enforce mfa
resource "aws_iam_policy" "enforce_mfa_policy" {
    name = "Enforce-MFA-Policy"
    path = "/"
    description = "Enforces users to add MFA to their account before accessing any other resources."
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "AllowViewGlobalPasswordPolicy"
                "Effect": "Allow",
                "Action": "iam:GetAccountPasswordPolicy",
                "Resource": "*"
            },
            {
                "Sid": "AllowViewAccountInfo",
                "Effect": "Allow",
                "Action": "iam:ListVirtualMFADevices",
                "Resource": "*"
            },
            {
                "Sid": "AllowManageOwnVirtualMFADevice",
                "Effect": "Allow",
                "Action": [
                    "iam:CreateVirtualMFADevice"
                ],
                "Resource": "arn:aws:iam::*:mfa/*"
            },
            {
                "Sid": "AllowManageOwnUserMFA",
                "Effect": "Allow",
                "Action": [
                    "iam:DeactivateMFADevice",
                    "iam:EnableMFADevice",
                    "iam:GetUser",
                    "iam:GetMFADevice",
                    "iam:ListMFADevices",
                    "iam:ResyncMFADevice"
                ],
                "Resource": [
                    "arn:aws:iam::*:user/*/$${aws:username}"
                ]
            },
            {
                "Sid": "DenyAllExceptListedIfNoMFA",
                "Effect": "Deny",
                "NotAction": [
                    "iam:GetAccountPasswordPolicy",
                    "iam:ChangePassword",
                    "iam:CreateVirtualMFADevice",
                    "iam:EnableMFADevice",
                    "iam:GetUser",
                    "iam:ListMFADevices",
                    "iam:ListVirtualMFADevices",
                    "iam:ResyncMFADevice",
                    "sts:GetSessionToken"
                ],
                "Resource": "*",
                "Condition": {
                    "BoolIfExists": {
                        "aws:MultiFactorAuthPresent": "false"
                    }
                }
            }
        ]
    })
}

# Creating iam policy to grant cost explorer access
resource "aws_iam_policy" "cost_explorer_access_policy" {
    name = "Cost-Explorer-Access-Policy"
    path = "/"
    description = "Grants users permissions to view, create, update, and delete using the Cost Explorer reports page."
    policy = jsonencode({
        "Version":"2012-10-17",
        "Statement": [
            {
                "Sid": "VisualEditor0",
                "Effect": "Allow",
                "Action": [
                    "aws-portal:ViewBilling",
                    "ce:CreateReport",
                    "ce:UpdateReport",
                    "ce:DeleteReport"
                ],
                "Resource": "*"
            }
        ]
    })
}

resource "aws_iam_account_password_policy" "strict" {
    minimum_password_length        = 14
    require_lowercase_characters   = true
    require_numbers                = true
    require_uppercase_characters   = true
    require_symbols                = true
    allow_users_to_change_password = true
}