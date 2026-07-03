# Create local variables for iam_groups
locals  {
    # Map of IAM groups and their associated managed policy ARNs
    iam_groups = {
        developers = {
            path = "/teams/"
            policy_arns = [
                "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
                "arn:aws:iam::aws:policy/AmazonS3FullAccess",
                aws_iam_policy.enforce_mfa_policy.arn
            ]
        }
        operations = {
            path = "/teams/"
            policy_arns = [
                "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
                "arn:aws:iam::aws:policy/AWSSystemsManagerForSAPFullAccess",
                "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
                aws_iam_policy.enforce_mfa_policy.arn
            ]
        }
        finance = {
            path = "/teams/"
            policy_arns = [
                "arn:aws:iam::aws:policy/AWSBudgetsActionsWithAWSResourceControlAccess",
                aws_iam_policy.cost_explorer_access_policy.arn,
                aws_iam_policy.enforce_mfa_policy.arn
            ]
        }
        analysts = {
            path = "/teams/"
            policy_arns = [
                "arn:aws:iam::aws:policy/AmazonS3FullAccess",
                "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess",
                aws_iam_policy.enforce_mfa_policy.arn
            ]
        }
    }

    # Flatten iam_groups by name and policy arn for attachment 
    group_policy_attachments = flatten([
        for group_name, group_config in local.iam_groups: [
            for group_policy_arn in group_config.policy_arns: {
                group = group_name
                policy_arn = group_policy_arn
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
    for_each = tomap({
        for item in local.group_policy_attachments : "${item.group}-${item.policy_arn}" => item
    })

    group = aws_iam_group.groups[each.value.group].name
    policy_arn = each.value.policy_arn
}