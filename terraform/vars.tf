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
  default = "ami-07213c5ae01c1dd51"
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

variable "applicationSecurityGroupName" {
  default = "application_security_group"
}

variable "applicationSecurityGroupDescription" {
  default = "ami ec2 application security group"
}

variable "databaseSecurityGroupName" {
  default = "database_security_group"
}

variable "databaseSecurityGroupDescription" {
  default = "ec2 database security group"
}

variable "s3_bucket_rule_id" {
  default = "ia_transition_rule"
}

variable "rds_parameter_group_name" {
  default = "rds-parameter-group"
}

variable "rds_parameter_group_description" {
  default = "Custom parameter group for rds instance"
}

variable "rds_subnet_group_name" {
  default = "rds_subnet_group"
}

variable "rds_parameter_group_family" {
  default = "mysql8.0"
}

variable "rds_engine" {
  default = "mysql"
}

variable "rds_instance_class" {
  default = "db.t3.micro"
}

variable "rds_identifier" {
  default = "csye6225"
}

variable "rds_username" {
  default = "csye6225"
}

variable "rds_password" {
  default = ""
}

variable "rds_db_name" {
  default = "csye6225"
}

variable "rds_allocated_storage" {
  default = 10
}

variable "s3_bucket_acl" {
  default = "private"
}

variable "webapp_transition_status" {
  default = "Enabled"
}

variable "webapp_transition_days" {
  default = 30
}

variable "webapp_transition_storage" {
  default = "STANDARD_IA"
}

variable "server_port" {
  default = "8080"
}

variable "ec2_iam_policy_name" {
  default = "WebAppS3"
}

variable "ec2_iam_policy_description" {
  default = "EC2 S3 access"
}

variable "ec2_iam_role_name" {
  default = "EC2-CSYE6225"
}

variable "ec2_iam_role_description" {
  default = "EC2 IAM role"
}

variable "iam_instance_profile_name" {
  default = "ec2_s3_access_profile"
}

variable "hosted_zone" {
  default = "Z00669351FYNF92T1SBKI"
}

variable "publish_metrics" {
  default = "true"
}

variable "metrics_server_hostname" {
  default = "localhost"
}

variable "metrics_server_port" {
  default = "8125"
}

variable "lb_security_group_name" {
  default = "load-balancer-security-group"
}

variable "lb_security_group_description" {
  default = "load balancer security group"
}

variable "asg_name" {
  default = "webapp-asg"
}

variable "scale_up_policy_name" {
  default = "cpu-scale-up-policy"
}

variable "scale_down_policy_name" {
  default = "cpu-scale-down-policy"
}

variable "asg_policy_adjustment_type" {
  default = "ChangeInCapacity"
}

variable "asg_policy_type" {
  default = "SimpleScaling"
}

variable "lb_name" {
  default = "webapp-lb"
}

variable "alb_name" {
  default = "webapp-lb-target-group"
}