#VPC ID
output "jenkins-vpc-id" {
  value = aws_vpc.main.id
}

#Public Subnet IDS
output "jenkins-public-subnet-id" {
  value = aws_subnet.main-public.*.id
}


#Private Subnet IDS
output "jenkins-private-subnet-id" {
  value = aws_subnet.main-private.*.id
}