# Creating the Managed IAM Policy
resource "aws_iam_policy" "enforce_mfa_policy" {
    name = "Enforce-MFA-Policy"
    path = "/"
    description = "Enforces users to add MFA to their account before accessing any other resources."
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
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
                "Resource": "arn:aws:iam::*:user/$${aws:username}"
            },
            {
                "Sid": "DenyAllExceptListedIfNoMFA",
                "Effect": "Deny",
                "NotAction": [
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