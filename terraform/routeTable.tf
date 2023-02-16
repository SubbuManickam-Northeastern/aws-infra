resource "aws_route_table" "public" {
  vpc_id = aws_vpc.awsVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.InternetGateway.id
  }
  tags = {
    "Name" = var.PublicRouteTableName
  }
}

resource "aws_route_table_association" "subnet_public" {
  count          = length(var.PublicSubnetNames)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.awsVPC.id
  tags = {
    "Name" = var.PrivateRouteTableName
  }
}

resource "aws_route_table_association" "subnet_private" {
  count          = length(var.PrivateSubnetNames)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}