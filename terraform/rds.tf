resource "aws_db_parameter_group" "rds_parameter_group" {
  name        = var.rds_parameter_group_name
  family      = var.rds_parameter_group_family
  description = var.rds_parameter_group_description
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = var.rds_subnet_group_name
  subnet_ids = [aws_subnet.private_subnet[0].id, aws_subnet.private_subnet[1].id]
}

resource "aws_db_instance" "webapp_rds" {
  engine               = var.rds_engine
  instance_class       = var.rds_instance_class
  multi_az             = false
  identifier           = var.rds_identifier
  username             = var.rds_username
  password             = var.rds_password
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.id
  publicly_accessible  = false
  db_name              = var.rds_db_name
  allocated_storage    = var.rds_allocated_storage
  skip_final_snapshot  = true
  apply_immediately    = true

  parameter_group_name = aws_db_parameter_group.rds_parameter_group.id

  vpc_security_group_ids = [aws_security_group.database_security_group.id]
}

resource "aws_security_group" "database_security_group" {
  name        = var.databaseSecurityGroupName
  description = var.databaseSecurityGroupDescription
  vpc_id      = aws_vpc.awsVPC.id

  ingress {
    description     = "MySQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.application_security_group.id]
  }

  tags = {
    "Name" = var.databaseSecurityGroupName
  }
}