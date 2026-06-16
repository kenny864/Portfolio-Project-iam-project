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

# local variables
locals {
    # Developers group policy list
    developers_policy_list = [
        "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
        "arn:aws:iam::aws:policy/AmazonS3FullAccess",
        aws_iam_policy.enforce_mfa_policy.arn
    ]


    # Operations group policy list
    operations_policy_list = [
        "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
        "arn:aws:iam::aws:policy/AWSSystemsManagerForSAPFullAccess",
        "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
        aws_iam_group.enforce_mfa_policy.arn
    ]

    # Finance group policy list
    finance_policy_list = [
        "arn:aws:iam::aws:policy/AWSBudgetsActionsWithAWSResourceControlAccess",
        aws_iam_group.cost_explorer_access_policy.arn,
        aws_iam_group.enforce_mfa_policy.arn
    ]

    # Analysts group policy list
    analysts_policy_list = [
        "arn:aws:iam::aws:policy/AmazonS3FullAccess",
        "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess",
        aws_iam_group.enforce_mfa_policy.arn
    ]
}

# Create Developer User Group
resource "aws_iam_group" "developers" {
    name = "Developer"
    path = "/"
}

# Attaching developers policy list to Developer group
resource "aws_iam_group_policy_attachment" "attach_developers_policies" {
    for_each = toset(local.developers_policy_list)
    group = aws_iam_group.developers.name
    policy_arn = each.value
}

# Create Operations User Group
resource "aws_iam_group" "operations" {
    name = "Operations"
    path = "/"
}

# Attaching operations policy list to Operations group
resource "aws_iam_group_policy_attachment" "attach_operations_policies" {
    for_each = toset(local.operations_policy_list)
    group = aws_iam_group.operations.name
    policy_arn = each.value
}

# Create Finance User Group
resource "aws_iam_group" "finance" {
    name = "Finance"
    path = "/"
}

# Attaching finance policy list to Finance group
resource "aws_iam_group_policy_attachment" "attach_finance_policies" {
    for_each = toset(local.finance_policy_list)
    group = aws_iam_group.finance.name
    policy_arn = each.value
}

# Create Analysts User Group
resource "aws_iam_group" "analysts" {
    name = "Analysts"
    path = "/"
}

resource "aws_iam_group_policy_attachment" "attach_analysts_policies" {
    for_each = toset(local.analysts_policy_list)
    group = aws_iam_group.analysts.name
    policy_arn = each.value
}

