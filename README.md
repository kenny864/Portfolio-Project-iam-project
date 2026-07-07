# Portfolio-Project-iam-project

## Overview

This project uses Terraform to automate AWS IAM user provisioning while enforcing security best practices.

Instead of manually creating IAM users, groups, and policies through the AWS Console, this project provisions them as code using Infrastructure as Code (IaC). User accounts are generated from a CSV file, assigned to the appropriate IAM groups, and required to enable Multi-Factor Authentication (MFA) before gaining access to AWS services.

This project demonstrates how Terraform can be used to automate identity management in AWS while improving security, consistency, and scalability.

## Features

- Creates multiple IAM user groups
- Creates IAM policies for each group
- Automatically provisions IAM users from a CSV file
- Assigns users to the appropriate IAM group
- Enforces Multi-Factor Authentication (MFA) for all newly created users
- Uses Infrastructure as Code (IaC) to provide repeatable deployments

## Project Structure
.
├── main.tf
├── outputs.tf
├── providers.tf
├── state.tf
├── users.csv
└── README.md

## How it Works

1. Custom IAM policies are created.
2. Terraform reads user information from a CSV file.
3. IAM groups are created and assigned to the appropriate policies.
4. IAM users are created automatically.
5. Each user is added to the correct IAM group.
6. A policy requires users to configure Multi-Factor Authentication before accessing other AWS services.

This approach removes repetitive manual work while enforcing consistent security controls.

## Example CSV
firstname,lastname,department
alice,snow,developers
bob,martin,analysts
charlie,johnson,finance
david,davidson,operations

## Prerequisites
- AWS Account
- Terraform 1.x
- AWS CLI configured
- IAM permissions to create:
    - Users
    - Groups
    - Policies
    - Groups

## Usage
### Initialize Terraform
terraform init

### Review and Deploy IAM Policies Infanstructure
terraform plan -target=aws_iam_policy.enforce_mfa_policy -target=aws_iam_policy.cost_explorer_access_policy
terraform apply -target=aws_iam_policy.enforce_mfa_policy -target=aws_iam_policy.cost_explorer_access_policy

### Review and Deploy IAM Remaining Infanstructure
terraform plan
terraform apply

### Destroy Infanstructure
terraform destroy

## Encryption Key
In main.tf line 209, replace the pgp_key with the user key.
In the users.csv, you can an additional column for each user's individual pgp key and return the encrypted password to the user.

## Skills Demonstrated
- Terraform
- Infrastructure as Code (IaC)
- AWS Identity and Access Management (IAM)
- IAM Users
- IAM Groups
- IAM Policies
- IAM Policy Attachments
- User Provisioning Automation
- CSV Data Processing
- Security Automation
- Principle of Least Privilege
- Multi-Factor Authentication (MFA)

## Security

This project follows several AWS security best practices:
- Uses IAM Groups instead of assigning permissions directly to users
- Enforces Multi-Factor Authentication for new users
- Supports least-privilege access through group-based permissions
- Automates user provisioning to reduce manual configuration errors

## Future Improvements

Potential enhancements include:
- Support for custom IAM roles
- Password generation and secure delivery
- AWS IAM Identity Center (AWS SSO) integration
- Remote Terraform state using Amazon S3 and DynamoDB state locking
- CI/CD deployment using GitHub Actions
- Additional validation for CSV input
- Unit testing with Terraform testing frameworks

## Learning Objectives

This project was created to strengthen practical experience with:

- AWS IAM
- Terraform
- Infrastructure as Code
- Cloud security best practices
- Identity and access management automation

## Challenges & Lessons Learned

The two main challenges I had when creating this project were creating the MFA Enforcement Policy and using for_each.

For the MFA Enforcement Policy, I had to figure out what necessary policies are needed for a new user to login and set up their MFA. When I tested this out, there were many times when the user was unable to set a new password, view their security credentials, and even setup an MFA. Using the AWS documentation, I figured out the list of policies needed.

For for_each, I kept running into an issue where a terraform command required data in the form of a map or list, but I provided the data in the form of a tuple. I come from a Java background where tuples don't exsist, so I was confused why it wouldn't just work with the tuple. I realized that I needed to use for_each to change the tuple to the data form that I needed.

The biggest lesson I learned was to test, test, and test some more.
It's fine if something doesn't work on a small project like this, but a failure for a company will hurt the product and more importantly the customer's trust. 

## Author

Kenny Jean-Baptiste

If you're a recruiter or hiring manager, I'd be happy to discuss this project or my cloud engineering journey.