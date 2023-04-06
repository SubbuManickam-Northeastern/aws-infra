resource "aws_security_group" "application_security_group" {
  name        = var.applicationSecurityGroupName
  description = var.applicationSecurityGroupDescription
  vpc_id      = aws_vpc.awsVPC.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  ingress {
    description = "Java"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.load_balancer_security_group.id]
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