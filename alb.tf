#Jenkins Controller Load Balancer
resource "aws_lb" "jenkins-load-balancer" {
  name            = var.JENKINS_LOAD_BALANCER_NAME
  security_groups = [aws_security_group.sg_jenkins_lb.id]
  subnets         = var.public_subnets
}
#Jenkins Controller Target Group
resource "aws_lb_target_group" "jenkins-target_group" {
  name        = var.JENKINS_TARGET_GROUP_NAME
  port        = "8080"
  protocol    = "HTTP"
  vpc_id      =  var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
  }
}
#App Listener HTTP
resource "aws_lb_listener" "jenkins-lb-listener" {
  load_balancer_arn = aws_lb.jenkins-load-balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.jenkins-target_group.arn
    type             = "forward"
  }
}