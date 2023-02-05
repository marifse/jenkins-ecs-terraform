#AWS Keys & Region
variable "AWS_REGION"{
default = "us-east-1"
}    
variable "AWS_ACCESS_KEY" {
       default  = "AKIA6Q7BSPSXPNJWOIHR"
}
variable "AWS_SECRET_KEY" {
default         = "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"
}

variable "ecr_repo_name" {
  default = "mycompany/jenkins"
  description = "Jenkins ECR Repo Name."
}