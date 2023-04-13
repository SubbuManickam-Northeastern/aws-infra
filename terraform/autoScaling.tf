resource "aws_security_group" "load_balancer_security_group" {
  name        = var.lb_security_group_name
  description = var.lb_security_group_description
  vpc_id      = aws_vpc.awsVPC.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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

# resource "aws_launch_configuration" "app_launch_config" {
#   image_id                    = var.ami
#   instance_type               = var.amiInstanceType
#   key_name                    = var.ec2Key
#   associate_public_ip_address = true

#   user_data = <<EOF
#     #!/bin/bash 
#     sudo echo "server.port=${var.server_port}" >> /tmp/userdata.properties
#     sudo echo "spring.datasource.url=jdbc:mysql://${aws_db_instance.webapp_rds.endpoint}/${aws_db_instance.webapp_rds.db_name}" >> /tmp/userdata.properties
#     sudo echo "spring.datasource.username=${aws_db_instance.webapp_rds.username}" >> /tmp/userdata.properties
#     sudo echo "spring.datasource.password=${aws_db_instance.webapp_rds.password}" >> /tmp/userdata.properties
#     sudo echo "spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver" >> /tmp/userdata.properties
#     sudo echo "spring.jpa.database-platform=org.hibernate.dialect.MySQL5InnoDBDialect" >> /tmp/userdata.properties
#     sudo echo "spring.jpa.hibernate.ddl-auto=update" >> /tmp/userdata.properties
#     sudo echo "s3.bucketName=${aws_s3_bucket.webapp_bucket.id}" >> /tmp/userdata.properties
#     sudo echo "publish.metrics=${var.publish_metrics}" >> /tmp/userdata.properties
#     sudo echo "metrics.server.hostname=${var.metrics_server_hostname}" >> /tmp/userdata.properties
#     sudo echo "metrics.server.port=${var.metrics_server_port}" >> /tmp/userdata.properties
#     sudo systemctl daemon-reload
#     sudo systemctl start java_app.service
#     sudo systemctl enable java_app.service
#     sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/tmp/cloudwatch_config.json -s
#   EOF

#   iam_instance_profile = aws_iam_instance_profile.ec2_s3_access_profile.name
#   security_groups      = [aws_security_group.application_security_group.id]
#   root_block_device {
#     delete_on_termination = true
#     volume_size = var.ec2Size
#     volume_type = var.ec2Volume
#   }
# }

resource "aws_autoscaling_group" "webapp_asg" {
  name                = var.asg_name
  min_size            = 1
  max_size            = 3
  desired_capacity    = 1
  default_cooldown    = 60
  vpc_zone_identifier = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id]
  # launch_configuration = aws_launch_configuration.app_launch_config.name
  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = var.asg_name
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "scale_up_policy" {
  name                   = var.scale_up_policy_name
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  adjustment_type        = var.asg_policy_adjustment_type
  policy_type            = var.asg_policy_type
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name          = "scale-up-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 5
  alarm_description   = "Alarm for scale up"
  alarm_actions       = [aws_autoscaling_policy.scale_up_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
}

resource "aws_autoscaling_policy" "scale_down_policy" {
  name                   = var.scale_down_policy_name
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  adjustment_type        = var.asg_policy_adjustment_type
  policy_type            = var.asg_policy_type
  scaling_adjustment     = -1
  cooldown               = 300
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name          = "scale-down-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 3
  alarm_description   = "Alarm for scale down"
  alarm_actions       = [aws_autoscaling_policy.scale_down_policy.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.webapp_asg.name
  }
}

resource "aws_lb" "load_balancer" {
  name                       = var.lb_name
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.load_balancer_security_group.id]
  subnets                    = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id]
  enable_deletion_protection = false
  tags = {
    "Application" = "Webapp"
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  name        = var.alb_name
  target_type = "instance"
  vpc_id      = aws_vpc.awsVPC.id
  port        = 8080
  protocol    = "HTTP"
  health_check {
    path     = "/healthz"
    protocol = "HTTP"
    interval = 300
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }
  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = "arn:aws:acm:us-east-1:332779329231:certificate/47ac0a05-2e34-467c-b5fd-43fd97749b4b"
}

resource "aws_autoscaling_attachment" "lb_autoscaling_attchment" {
  autoscaling_group_name = aws_autoscaling_group.webapp_asg.name
  lb_target_group_arn    = aws_lb_target_group.alb_target_group.arn
}

resource "aws_kms_key" "ec2_encryption" {
  description             = "EC2 encryption key"
  deletion_window_in_days = 15
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:ScheduleKeyDeletion"
        ]
        Resource = "*"
      },
      {
        Sid       = "Allow key owner to update key policy"
        Effect    = "Allow"
        Principal = {
          AWS = "*"
        }
        Action    = [
          "kms:PutKeyPolicy",
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:ScheduleKeyDeletion"
        ]
        Resource  = "*"
      }
    ]
  })
  tags = {
    "Name" = "ec2-encryption"
  }
}


resource "aws_launch_template" "app_launch_template" {
  name                   = "webapp-template"
  image_id               = var.ami
  instance_type          = var.amiInstanceType
  key_name               = var.ec2Key
  vpc_security_group_ids = [aws_security_group.application_security_group.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_s3_access_profile.name
  }
  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size           = var.ec2Size
      volume_type           = var.ec2Volume
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = aws_kms_key.ec2_encryption.arn
    }
  }
  tags = {
    "Name" = "webapp-ec2"
  }
  user_data = base64encode(<<EOF
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
  )
}