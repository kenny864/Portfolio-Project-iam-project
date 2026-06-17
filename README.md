# Portfolio-Project-iam-project

## Description
This project uses AWS and Terraform. 

I will create several user groups with their individual authorization. 
Then I will create several users and assign them to their appropriate user groups. 
Each User will be required to setup MFA before they gain authorization to anything else.

## Terraform Launch Order
terraform plan -target=aws_iam_policy.enforce_mfa_policy -target=aws_iam_policy.cost_explorer_access_policy
terraform apply -target=aws_iam_policy.enforce_mfa_policy -target=aws_iam_policy.cost_explorer_access_policy
terraform plan
terraform apply
