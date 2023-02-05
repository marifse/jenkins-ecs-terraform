#Security Group for Jenkins Load Balancer
resource "aws_security_group" "sg_jenkins_lb" {
  name        = "sg_jenkins_lb"
  description = "Allow 80 and 443 inbound traffic"
  vpc_id      = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = [var.LB_JENKINS_CIDR_IN]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [var.LB_JENKINS_CIDR_IN]
  }
}

#Security Group for Jenkins Fargate Instances
resource "aws_security_group" "sg_jenkins_fargate" {
  name        = "sg_jenkins_fargate"
  description = "Allow 8080 inbound traffic"
  vpc_id      = var.vpc_id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
    security_groups = ["${aws_security_group.sg_jenkins_lb.id}"]
  }
}
resource "aws_security_group_rule" "allow_agents_to_jks_jnlp_port" {
  for_each          = var.private_subnets
  security_group_id = aws_security_group.sg_jenkins_fargate.id
  from_port         = var.controller_jnlp_port
  to_port           = var.controller_jnlp_port
  protocol          = "tcp"
  type              = "ingress"
  cidr_blocks       = ["${data.aws_network_interface.each_network_interface[each.key].private_ip}/32"]
  description       = "From the NLB to the Jenkins Controller via JNLP and ENI ${data.aws_network_interface.each_network_interface[each.key].id}."
}

# When using a private nlb we need to have this rule for nlb health check to work.
resource "aws_security_group_rule" "from_private_nlb_network_interfaces" {
  for_each          = var.private_subnets
  security_group_id = aws_security_group.sg_jenkins_fargate.id
  from_port         = var.controller_listening_port
  to_port           = var.controller_listening_port
  protocol          = "tcp"
  type              = "ingress"
  cidr_blocks       = ["${data.aws_network_interface.each_network_interface[each.key].private_ip}/32"]
  description       = "From the NLB to the Jenkins Controller via HTTP and ENI ${data.aws_network_interface.each_network_interface[each.key].id}. Required for health check."
}

resource "aws_security_group" "jenkins_agents" {
  name        = "sgr-jenkins-agents"
  description = "Security group attached to Jenkins agents running in Fargate."
  vpc_id      = var.vpc_id
  tags        = { "Name" : "sgr-jenkins-agents" }
}

resource "aws_security_group_rule" "jenkins_agent_egress" {
  security_group_id = aws_security_group.jenkins_agents.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

#Security Group for EFS Access
resource "aws_security_group" "ecs_efs_access" {
  name        = "ecs_efs_access"
  description = "Allow access to the Persistent EFS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
    security_groups = ["${aws_security_group.sg_jenkins_fargate.id}",]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

