terraform {
  backend "s3" {
    region         = "eu-west-2"
    bucket         = "jenkins-terraform-backend-1"
    key            = "vpc.terraform.tfstate"
  }
}
