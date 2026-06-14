terraform {
  backend "s3" {
    bucket = "kjb-state-iam-project-627330319869-us-east-1-an"
    key = "global/s3/terraform.tfstate"
    region = "us-east-1"
    use_lockfile = true
  }
}