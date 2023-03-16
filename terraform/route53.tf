resource "aws_route53_record" "a_record_setup" {
  zone_id = var.hosted_zone
  name    = ""
  type    = "A"
  records = ["${aws_instance.webapp_ec2.public_ip}"]
  ttl     = 60
}