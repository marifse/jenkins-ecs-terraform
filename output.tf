#Load Balancer URL for Jenkins
output "jenkins-load-balancer-name" {
  value = aws_lb.jenkins-load-balancer.dns_name
}

#Target Group ARN for Jenkins
output "jenkins-target-group-arn" {
  value = aws_lb_target_group.jenkins-target_group.arn
}

output "controller_log_group" {
  description = "Jenkins controller log group"
  value       = aws_cloudwatch_log_group.jenkins_controller.name
}

output "agents_log_group" {
  description = "Jenkins agents log group"
  value       = aws_cloudwatch_log_group.agents.name
}

output "jenkins_credentials" {
  description = "Credentials to access Jenkins via the public URL"
  sensitive   = true
  value = {
    username = "admin"
    password = random_password.admin_password.result
  }
}

output "controller_config_on_s3" {
  description = "Jenkins controller configuration file on S3"
  value       = "s3://${aws_s3_object.jenkins_conf.bucket}/${aws_s3_object.jenkins_conf.key}"
}