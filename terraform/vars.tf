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