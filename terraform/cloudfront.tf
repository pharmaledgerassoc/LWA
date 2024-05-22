# --- 7-lwa-app-deployment-pla/cloudfront.tf ---

data "aws_cloudfront_cache_policy" "main" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_origin_request_policy" "main" {
  name = "Managed-CORS-S3Origin"
}

resource "random_pet" "viewer_response_function" {
  length = 1
}
resource "aws_cloudfront_function" "viewer_response_function" {
  name = "${replace(local.fqdn, ".", "-")}_csp_${random_pet.viewer_response_function.id}"

  runtime = "cloudfront-js-1.0"
  publish = true
  code    = templatefile("${path.module}/files/viewer_response_function.js.tftpl", { connect_src = local.csp_connect_src, frame_src = local.csp_frame_src, frame_src_unsafe_hashes = local.csp_frame_src_unsafe_hashes, script_src_unsafe_hashes = chomp(local.csp_script_src_unsafe_hashes) })

  lifecycle {
    create_before_destroy = true
  }
}

module "cloudfront" {
  depends_on = [
    aws_acm_certificate_validation.main
  ]

  source  = "terraform-aws-modules/cloudfront/aws"
  version = "~> 3.2.1"

  aliases             = [local.fqdn, "www.${local.fqdn}"]
  http_version        = "http2and3"
  comment             = local.fqdn
  is_ipv6_enabled     = false
  wait_for_deployment = true

  create_origin_access_control = true
  origin_access_control = {
    "${local.fqdn}.s3.eu-west-1.amazon.aws.com" : {
      "description" : "",
      "origin_type" : "s3",
      "signing_behavior" : "always",
      "signing_protocol" : "sigv4"
    }
  }

  origin = {
    "${local.fqdn}.s3.eu-west-1.amazon.aws.com" = {
      domain_name           = module.s3_bucket.s3_bucket_bucket_regional_domain_name
      origin_access_control = "${local.fqdn}.s3.eu-west-1.amazon.aws.com"
    }
  }

  default_cache_behavior = {
    target_origin_id = "${local.fqdn}.s3.eu-west-1.amazon.aws.com"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]

    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.main.id
    cache_policy_id          = data.aws_cloudfront_cache_policy.main.id

    use_forwarded_values = false

    function_association = {
      viewer-response = {
        function_arn = aws_cloudfront_function.viewer_response_function.arn
      }
    }
  }

  viewer_certificate = {
    acm_certificate_arn      = aws_acm_certificate.main.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  default_root_object = local.cloudfront_default_root_object

  custom_error_response = local.custom_error_response_4xx
}

resource "aws_route53_record" "main" {
  name = local.fqdn
  type = "A"

  zone_id = data.aws_route53_zone.main.zone_id

  alias {
    name    = module.cloudfront.cloudfront_distribution_domain_name
    zone_id = "Z2FDTNDATAQYW2"

    evaluate_target_health = true
  }

  allow_overwrite = true
}
resource "aws_route53_record" "www" {
  name = "www.${local.fqdn}"
  type = "A"

  zone_id = data.aws_route53_zone.main.zone_id

  alias {
    name    = module.cloudfront.cloudfront_distribution_domain_name
    zone_id = "Z2FDTNDATAQYW2"

    evaluate_target_health = true
  }

  allow_overwrite = true
}
