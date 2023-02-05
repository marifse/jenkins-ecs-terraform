# aws provider variables
variable "AZ_COUNT" {
  default = "3"
}
variable "profile" {
  default = ""
}
variable "AWS_REGION" {
  default = "eu-west-2"
}
variable "RESOURCE_TAG" {
  default = "Jenkins_ECS"
}

#input variables
variable "private_subnets" {
  description = "Private subnets to deploy Jenkins and the internal NLB"
  type        = set(string)
}

variable "public_subnets" {
  description = "Public subnets to deploy the load balancer"
  type        = set(string)
}

variable "vpc_id" {
  description = "The VPC id"
  type        = string
}


#ECS variables
variable "ECS_CLUSTER_NAME" {
  default = "JenkinsCluster"
}
variable "JENKINS_FARGATE_TASK_COUNT" {
  default = "1"
}
variable "JENKINS_FARGATE_CPU" {
  default = "1024"
}
variable "JENKINS_FARGATE_MEMORY" {
  default = "2048"
}
#variable JenkinsAppContainer_CIDR_IN {
#  default = "0.0.0.0/0"
#}
variable "JENKINS_LOGS" {
  default = "JenkinsLogs"
}
variable "controller_docker_image" {
  default = "elmhaidara/jenkins-aws-fargate:2.338"
}
variable "JENKINS_ENVIRONMENT" {
  default = "Dev"
}
variable "controller_log_retention_days" {
  default = "30"
}
variable "controller_listening_port" {
  default = "8080"
}
variable "controller_jnlp_port" {
  default = "50000"
}
variable "controller_java_opts" {
  default = ""
}
variable "controller_docker_user_uid_gid" {
  default = 0
}
variable "fargate_platform_version" {
default = "1.4.0"
}
variable "controller_deployment_percentages" {
  description = "The Min and Max percentages of Controller instance to keep when updating the service. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/update-service.html"
  type = object({
    min = number
    max = number
  })
  default = {
    min = 0
    max = 100
  }
}

#agent variables
variable "agents_cpu_memory" {
  description = "CPU and memory for the agent example. Note that all combinations are not supported with Fargate."
  type = object({
    memory = number
    cpu    = number
  })
  default = {
    memory = 2048
    cpu    = 1024
  }
}
variable "agent_docker_image" {
  default = "elmhaidara/jenkins-alpine-agent-aws:latest-alpine"  
}
variable "controller_num_executors" {
  type        = number
  description = "Set this to a number > 0 to be able to build on controller (NOT RECOMMENDED)"
  default     = 0
}
variable "agents_log_retention_days" {
  description = "Retention days for Agents log group"
  type        = number
  default     = 5
}

#EFS variables
#variable EFS_CIDR_IN {
#  default = "0.0.0.0/0"
#}
variable "efs_burst_credit_balance_threshold" {
  type        = number
  description = "Threshold below which the metric BurstCreditBalance associated alarm will be triggered. Expressed in bytes"
  default     = 1154487209164 # half of the default credits
}

#Load Balancer & Autoscaling
variable "LB_JENKINS_CIDR_IN" {
  default = "0.0.0.0/0"
}
variable "JENKINS_TARGET_GROUP_NAME" {
  default = "jenkins-target-group"
}
variable "JENKINS_LOAD_BALANCER_NAME" {
  default = "jenkins-load-balancer"
}
variable "JENKINS_COUNT_MIN" {
  default = "1"
}
variable "JENKINS_COUNT_MAX" {
  default = "2"
}

#s3 variables
#variable "BUCKET_NAME_WPCONTENT" {}

#iam variables
#variable "Jems_ECSTaskExecutionRole" {}
#variable "POLICY_IAMUSER" {}


