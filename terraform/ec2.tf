resource "aws_instance" "webapp_ec2" {
  ami                    = var.ami
  instance_type          = var.amiInstanceType
  subnet_id              = aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.application_security_group.id]
  key_name               = var.ec2Key
  iam_instance_profile   = aws_iam_instance_profile.ec2_s3_access_profile.name

  root_block_device {
    delete_on_termination = true
    volume_size           = var.ec2Size
    volume_type           = var.ec2Volume
  }

  user_data = <<EOF
    #!/bin/bash 
    sudo echo "server.port=${var.server_port}" >> /tmp/userdata.properties
    sudo echo "spring.datasource.url=jdbc:mysql://${aws_db_instance.webapp_rds.endpoint}/${aws_db_instance.webapp_rds.db_name}" >> /tmp/userdata.properties
    sudo echo "spring.datasource.username=${aws_db_instance.webapp_rds.username}" >> /tmp/userdata.properties
    sudo echo "spring.datasource.password=${aws_db_instance.webapp_rds.password}" >> /tmp/userdata.properties
    sudo echo "spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver" >> /tmp/userdata.properties
    sudo echo "spring.jpa.database-platform=org.hibernate.dialect.MySQL5InnoDBDialect" >> /tmp/userdata.properties
    sudo echo "spring.jpa.hibernate.ddl-auto=update" >> /tmp/userdata.properties
    sudo echo "s3.bucketName=${aws_s3_bucket.webapp_bucket.id}" >> /tmp/userdata.properties
    sudo echo "publish.metrics=${var.publish_metrics}" >> /tmp/userdata.properties
    sudo echo "metrics.server.hostname=${var.metrics_server_hostname}" >> /tmp/userdata.properties
    sudo echo "metrics.server.port=${var.metrics_server_port}" >> /tmp/userdata.properties
    sudo systemctl daemon-reload
    sudo systemctl start java_app.service
    sudo systemctl enable java_app.service
    sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/tmp/cloudwatch_config.json -s
  EOF

  tags = {
    "Name" = var.ec2Name
  }
}

resource "aws_security_group" "application_security_group" {
  name        = var.applicationSecurityGroupName
  description = var.applicationSecurityGroupDescription
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
    description = "Java"
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
    "Name" = var.applicationSecurityGroupName
  }
}

resource "aws_iam_policy" "ec2_webapp_s3" {
  name        = var.ec2_iam_policy_name
  description = var.ec2_iam_policy_description
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListObject",
          "s3:DeleteObject"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.webapp_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.webapp_bucket.id}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "ec2_user" {
  name        = var.ec2_iam_role_name
  description = var.ec2_iam_role_description
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "EC2_S3_role_attachment" {
  role       = aws_iam_role.ec2_user.name
  policy_arn = aws_iam_policy.ec2_webapp_s3.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  role       = aws_iam_role.ec2_user.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_s3_access_profile" {
  name = var.iam_instance_profile_name
  role = aws_iam_role.ec2_user.name
}