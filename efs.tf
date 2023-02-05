#EFS Folder for App Data
resource "aws_efs_file_system" "jenkins-data" {
  tags = {
    Name = "jenkins-data"
  }
}
resource "aws_efs_mount_target" "mount-jenkins" {
  for_each        = var.private_subnets
  #count           = var.AZ_COUNT
  file_system_id  = aws_efs_file_system.jenkins-data.id
  subnet_id       = each.value
  #subnet_id       = element(data.terraform_remote_state.jenkins-vpc-tfstate.outputs.jenkins-private-subnet-id, count.index)
  security_groups = ["${aws_security_group.ecs_efs_access.id}"]
}