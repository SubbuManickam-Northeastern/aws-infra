resource "aws_route53_record" "lb_alias" {
  zone_id = var.hosted_zone
  name    = ""
  type    = "A"
  alias {
    name                   = aws_lb.load_balancer.dns_name
    zone_id                = aws_lb.load_balancer.zone_id
    evaluate_target_health = true
  }
}