#autoscaling group for Jenkins
resource "aws_appautoscaling_target" "jenkins-target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.JenkinsCluster.name}/${aws_ecs_service.jenkins-service.name}"
  role_arn           = aws_iam_role.controller_ecs_execution_role.arn
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.JENKINS_COUNT_MIN
  max_capacity       = var.JENKINS_COUNT_MAX
}
#up policy for Jenkins
resource "aws_appautoscaling_policy" "jenkins_up" {
  name               = "jenkins_scale_up"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.JenkinsCluster.name}/${aws_ecs_service.jenkins-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.jenkins-target]
}
#down policy for Jenkins
resource "aws_appautoscaling_policy" "jenkins_down" {
  name               = "jenkins_scale_down"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.JenkinsCluster.name}/${aws_ecs_service.jenkins-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.jenkins-target]
}

# CloudWatch alarm that triggers the autoscaling up policy for Jenkins
resource "aws_cloudwatch_metric_alarm" "jenkins_service_cpu_high" {
  alarm_name          = "jenkins_cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "65"

  dimensions = {
    ClusterName = aws_ecs_cluster.JenkinsCluster.name
    ServiceName = aws_ecs_service.jenkins-service.name
  }

  alarm_actions = [aws_appautoscaling_policy.jenkins_up.arn]
}


# CloudWatch alarm that triggers the autoscaling down policy for Jenkins
resource "aws_cloudwatch_metric_alarm" "jenkins_service_cpu_low" {
  alarm_name          = "jenkins_cpu_utilization_low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    ClusterName = aws_ecs_cluster.JenkinsCluster.name
    ServiceName = aws_ecs_service.jenkins-service.name
  }

  alarm_actions = [aws_appautoscaling_policy.jenkins_down.arn]
}

