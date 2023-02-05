locals {
  jenkins_controller_container_name = "jenkins-controller"
  jenkins_home                      = "/var/jenkins_home"
  # Jenkins home inside the container. This is hard coded in the official docker image
  efs_volume_name    = "jenkins-data"
  #jenkins_host       = "${var.route53_subdomain}.${var.route53_zone_name}"
  #jenkins_public_url = var.route53_zone_name != "" ? "https://${local.jenkins_host}" : "http://${aws_alb.alb_jenkins_controller.dns_name}"
}

#Cluster creation
resource "aws_ecs_cluster" "JenkinsCluster" {
  name = var.ECS_CLUSTER_NAME
   setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "capacity_providers" {
  cluster_name       = aws_ecs_cluster.JenkinsCluster.name
  capacity_providers = ["FARGATE"]
}

#App Service Creation
resource "aws_ecs_service" "jenkins-service" {
  name             = "jenkins-controller"
  cluster          = aws_ecs_cluster.JenkinsCluster.id
  task_definition  = aws_ecs_task_definition.jenkins-td.arn
  desired_count    = var.JENKINS_FARGATE_TASK_COUNT
  launch_type      = "FARGATE"
  platform_version = var.fargate_platform_version //not specfying this version explictly will not currently work for mounting EFS to Fargate
  deployment_minimum_healthy_percent = var.controller_deployment_percentages.min
  deployment_maximum_percent         = var.controller_deployment_percentages.max
  
  network_configuration {
    security_groups  = [aws_security_group.sg_jenkins_fargate.id]
    subnets          = var.private_subnets
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.jenkins-target_group.id
    container_name   = local.jenkins_controller_container_name
    container_port   = "8080"
  }
  # nlb http for agents
  load_balancer {
    target_group_arn = aws_lb_target_group.nlb_agents_to_controller_http.arn
    container_name   = local.jenkins_controller_container_name
    container_port   = var.controller_listening_port
  }

  # nlb jnlp for agents
  load_balancer {
    target_group_arn = aws_lb_target_group.nlb_agents_to_controller_jnlp.arn
    container_name   = local.jenkins_controller_container_name
    container_port   = var.controller_jnlp_port
  }
  depends_on = [
	aws_lb_listener.jenkins-lb-listener, 
	aws_iam_role_policy_attachment.ecs_task_execution_role,
  	aws_lb_listener.agents_http_listener,
        aws_lb_listener.agents_jnlp_listener
  ]
}

#App Task-Definition
resource "aws_ecs_task_definition" "jenkins-td" {
  family                   = "jenkins-controller"
  execution_role_arn       = aws_iam_role.Jenkins_ECSTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.Jenkins_ECSTaskExecutionRole.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.JENKINS_FARGATE_CPU
  memory                   = var.JENKINS_FARGATE_MEMORY
  volume {
    name = local.efs_volume_name

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.jenkins-data.id
      root_directory = "/"
    }
  }

  container_definitions = templatefile("${path.module}/templates/ecs-task.template.json", {
    image             = var.controller_docker_image
    region            = var.AWS_REGION
    log_group_name    = aws_cloudwatch_log_group.jenkins_controller.id
    jenkins_http_port = var.controller_listening_port
    jenkins_jnlp_port = var.controller_jnlp_port
    env_vars = jsonencode([
      { name : "JENKINS_JAVA_OPTS", value : var.controller_java_opts },
      {
        name : "JENKINS_CONF_S3_URL",
        value : "s3://${aws_s3_object.jenkins_conf.bucket}/${aws_s3_object.jenkins_conf.key}"
      },
      # This will force the creation of a new version of the task definition if the configuration changes and cause ECS to launch
      # a new container.
      { name : "JENKINS_CONF_S3_VERSION_ID", value : aws_s3_object.jenkins_conf.version_id }
    ])
    jenkins_controller_container_name = local.jenkins_controller_container_name
    efs_volume_name                   = local.efs_volume_name
    jenkins_user_uid                  = var.controller_docker_user_uid_gid
    jenkins_home                      = local.jenkins_home
  })
}
  
}
