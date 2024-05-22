# --- 7-lwa-app-deployment-pla/acm.tf ---

resource "aws_acm_certificate" "main" {
  provider                  = aws.us_east_1
  domain_name               = local.fqdn
  subject_alternative_names = ["www.${local.fqdn}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_route53_record" "main_ssl_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]

  zone_id = data.aws_route53_zone.main.zone_id
  ttl     = 60

  allow_overwrite = true
}
resource "aws_acm_certificate_validation" "main" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.main_ssl_validation : record.fqdn]
}
