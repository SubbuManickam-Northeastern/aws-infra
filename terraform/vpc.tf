data "aws_availability_zones" "available" {}

resource "aws_vpc" "awsVPC" {
  cidr_block           = var.CIDR
  enable_dns_hostnames = true
  tags = {
    Name = var.VPCName
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.PublicSubnetNames)
  vpc_id                  = aws_vpc.awsVPC.id
  cidr_block              = cidrsubnet(var.CIDR, 8, count.index + 10)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = var.PublicSubnetNames[count.index]
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = length(var.PrivateSubnetNames)
  vpc_id                  = aws_vpc.awsVPC.id
  cidr_block              = cidrsubnet(var.CIDR, 8, count.index + 20)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = var.PrivateSubnetNames[count.index]
  }
}