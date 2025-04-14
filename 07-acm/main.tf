resource "aws_acm_certificate" "sivapractice" {
  domain_name       = "*.sivapractice.online"
  validation_method = "DNS"

  tags = merge(
    var.tags,
    var.common_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "sivapractice" {
  for_each = {
    for dvo in aws_acm_certificate.sivapractice.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 1
  type            = each.value.type
  zone_id         = data.aws_route53_zone.shivarampractice.zone_id
}

resource "aws_acm_certificate_validation" "sivapractice" {
  certificate_arn         = aws_acm_certificate.sivapractice.arn
  validation_record_fqdns = [for record in aws_route53_record.sivapractice : record.fqdn]
}