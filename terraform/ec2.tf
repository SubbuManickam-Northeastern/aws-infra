resource "aws_instance" "webapp_ec2" {
  ami                    = var.ami
  instance_type          = var.amiInstanceType
  subnet_id              = aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.application_security_group.id]
  key_name               = var.ec2Key

  root_block_device {
    delete_on_termination = true
    volume_size           = var.ec2Size
    volume_type           = var.ec2Volume
  }

  tags = {
    "Name" = var.ec2Name
  }
}

resource "aws_security_group" "application_security_group" {
  name        = var.securityGroupName
  description = var.securityGroupDescription
  vpc_id      = aws_vpc.awsVPC.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "MySQL"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = var.securityGroupName
  }

}