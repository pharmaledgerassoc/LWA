# --- 7-lwa-app-deployment-pla/main.tf ---

data "aws_route53_zone" "main" {
  name         = var.dns_domain
  private_zone = false
}

data "http" "bdns_json" {
  count = local.bdns_json_url_specified ? 1 : 0

  url = var.bdns_json_url

  request_headers = {
    Accept = "application/json"
  }

  lifecycle {
    postcondition {
      condition     = contains([200], self.status_code)
      error_message = "Status code invalid"
    }
  }
}

resource "local_file" "bdns_json" {
  filename = "${path.module}/bdns.json"

  content = local.bdns_json_url_specified ? data.http.bdns_json[0].response_body : file(local.bdns_json_local_path)
}

data "http" "environment_js_template" {
  url = local.https_url_environment_js_template
}
data "template_file" "environment_js" {
  template = data.http.environment_js_template.response_body
  vars = {
    epi_domain          = var.epi_domain,
    app_build_version   = var.app_build_version,
    time_per_call       = var.time_per_call,
    total_wait_time     = var.total_wait_time,
    gto_time_per_call   = var.gto_time_per_call,
    gto_total_wait_time = var.gto_total_wait_time,
    bdns_url            = local.bdns_url
  }
}
resource "local_file" "environment_js" {
  filename = "${path.module}/environment.js"

  content = data.template_file.environment_js.rendered
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.13.0"

  bucket = local.fqdn

  block_public_acls   = true
  block_public_policy = true

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  force_destroy = true
}
data "aws_iam_policy_document" "s3_bucket_policy" {
  version = "2012-10-17"
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.s3_bucket.s3_bucket_arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        module.cloudfront.cloudfront_distribution_arn
      ]
    }
  }
}
resource "aws_s3_bucket_policy" "main" {
  bucket = module.s3_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}
