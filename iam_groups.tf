# Creating IAM Policy to enforce mfa
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

# Define local variables
locals  {
    # Map of IAM groups and their associated managed policy ARNs
    iam_groups = {
        developers = {
            path = "/teams/"
            policy_arn = [
                "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
                "arn:aws:iam::aws:policy/AmazonS3FullAccess",
                aws_iam_policy.enforce_mfa_policy.arn
            ]
        }
        operations = {
            path = "/teams/"
            policy_arn = [
                "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
                "arn:aws:iam::aws:policy/AWSSystemsManagerForSAPFullAccess",
                "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
                aws_iam_policy.enforce_mfa_policy.arn
            ]
        }
        finance = {
            path = "/teams/"
            policy_arn = [
                "arn:aws:iam::aws:policy/AWSBudgetsActionsWithAWSResourceControlAccess",
                aws_iam_policy.cost_explorer_access_policy.arn,
                aws_iam_policy.enforce_mfa_policy.arn
            ]
        }
        analysts = {
            path = "/teams/"
            policy_arn = [
                "arn:aws:iam::aws:policy/AmazonS3FullAccess",
                "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess",
                aws_iam_policy.enforce_mfa_policy.arn
            ]
        }
    }

    # Flatten iam_groups by name and policy arn for attachment 
    group_policy_attachments = flatten([
        for group_name, group_config in local.iam_groups: [
            for policy_arn in group_config: {
                group = group_name
                policy_arn = policy_arn
            }
        ]
    ])
}

# Create User Groups
resource "aws_iam_group" "groups" {
    for_each = local.iam_groups
    
    name = each.key
    path = each.value.path
}

# Attach Policies to Groups
resource "aws_iam_group_policy_attachment" "attachments" {
    for_each = local.group_policy_attachments

    group = each.key
    policy_arn = each.value
}

