provider "aws" {
  profile    = var.profile
  region     = var.AWS_REGION
}
terraform {
  backend "s3" {
    region         = "eu-west-2"
    bucket         = "jenkins-terraform-backend-1"
    key            = "ecs.terraform.tfstate"
  }
}

#data "terraform_remote_state" "jenkins-vpc-tfstate" {
#  backend = "s3"
#  config = {
#    bucket  = "jenkins-terraform-backend-1"
#    key	    = "vpc.terraform.tfstate"
#    region  = "eu-west-2"
#  }
#}