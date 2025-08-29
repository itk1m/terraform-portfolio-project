terraform {
  backend "s3" {
    bucket = "ik-my-tf-website-state"
    key = "global/s3/terraform.tfstate"
    dynamodb_table = "my-db-website-table"
  }
}