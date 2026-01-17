terraform {
  backend "s3" {
    bucket         = "portfolio-2-tfstate-wr-242046727288-euc1"
    key            = "portfolio-2/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}
