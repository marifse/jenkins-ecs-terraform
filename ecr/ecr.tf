provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
  region     = var.AWS_REGION
}

resource "aws_ecr_repository" "jenkins" {
  name = var.ecr_repo_name
}

output "ecr_repo_url" {
  description = "The URL of the repository."
  value = aws_ecr_repository.jenkins.repository_url
}
