variable "REGION" {
  default = "us-east-1"
}

variable "PROFILE" {
  default = "dev"
}

variable "CIDR" {
  default = "0.0.0.0/0"
}

variable "PublicSubnetNames" {
  type    = list(any)
  default = []
}

variable "PrivateSubnetNames" {
  type    = list(any)
  default = []
}

variable "VPCName" {
  default = "TestVPC"
}

variable "GatewayName" {
  default = "TestGateway"
}

variable "PublicRouteTableName" {
  default = "PublucRouteTable"
}

variable "PrivateRouteTableName" {
  default = "PrivateRouteTable"
}

variable "ami" {
  default = "ami-00d1054d6853b2eee"
}

variable "ec2Key" {
  default = "ec2-aws"  
}

variable "ec2Volume" {
  default = "gp2"  
}

variable "ec2Size" {
  default = 50
}

variable "ec2Name" {
  default = "webapp-ec2-server"  
}

variable "amiInstanceType" {
  default = "t2.micro"
}

variable "securityGroupName" {
  default = "application_security_group"
}

variable "securityGroupDescription" {
  default = "ami ec2 application security group"
}