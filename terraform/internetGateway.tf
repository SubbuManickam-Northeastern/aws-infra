resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = aws_vpc.awsVPC.id
  tags = {
    "Name" = var.GatewayName
  }
}