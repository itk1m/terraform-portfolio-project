terraform {
  backend "s3" {
    bucket = "ik-my-terraform-state"
    key = "global/s3/terraform.tfstate"
    dynamodb_table = "terraform-lock-file"
  }
}