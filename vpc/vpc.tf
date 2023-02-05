provider "aws" {
  profile    = var.profile
  region     = var.AWS_REGION
}

data "aws_availability_zones" "available" {}

# VPC Setup
resource "aws_vpc" "main" {
  cidr_block           = var.VPC_CIDR_BLOCK
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  #enable_classiclink  = "false"
  tags = {
    Name = "main"
  }
}

# VPC Public Subnets
resource "aws_subnet" "main-public" {
  vpc_id                  = aws_vpc.main.id
  count                   = var.AZ_COUNT
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.RESOURCE_TAG}.public.${data.aws_availability_zones.available.names[count.index]}"
  }
}


# VPC Private Subnets
resource "aws_subnet" "main-private" {
  vpc_id            = aws_vpc.main.id
  count             = var.AZ_COUNT
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + length(aws_subnet.main-public.*.id))
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.RESOURCE_TAG}.private.${data.aws_availability_zones.available.names[count.index]}"
  }
}

# Internet GW
resource "aws_internet_gateway" "main-gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main"
  }
}

# NAT GW
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = element(aws_eip.nat-eip.*.id, count.index)
  subnet_id     = element(aws_subnet.main-public.*.id, count.index)
  count         = var.AZ_COUNT
}

#Elastic IP
resource "aws_eip" "nat-eip" {
  count = var.AZ_COUNT
  vpc   = true
}

# Route Table for Public Subnets
resource "aws_route_table" "main-rt-public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-gw.id
  }
  tags = {
    Name = "main-public-rt"
  }
}
# Route Table for Private Subnets
resource "aws_route_table" "main-rt-private" {
  vpc_id = aws_vpc.main.id
  count  = var.AZ_COUNT
  tags = {
    Name = "main-rt-private.${data.aws_availability_zones.available.names[count.index]}"
  }
}
#Route for Private Route Table
resource "aws_route" "private-route" {
  route_table_id         = element(aws_route_table.main-rt-private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat-gw.*.id, count.index)
  count                  = var.AZ_COUNT
  depends_on             = ["aws_route_table.main-rt-private"]
}

# Route Associations Public
resource "aws_route_table_association" "main-rta-public-1" {
  count          = var.AZ_COUNT
  subnet_id      = element(aws_subnet.main-public.*.id, count.index)
  route_table_id = aws_route_table.main-rt-public.id
}

# Route Associations Private
resource "aws_route_table_association" "main-rta-private-1" {
  count          = var.AZ_COUNT
  subnet_id      = element(aws_subnet.main-private.*.id, count.index)
  route_table_id = element(aws_route_table.main-rt-private.*.id, count.index)
}

