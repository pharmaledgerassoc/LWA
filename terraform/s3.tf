# --- s3.tf ---

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.1.2"

  bucket = var.fqdn

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

resource "aws_s3_object" "bdns_json" {
  depends_on = [
    local_file.bdns_json
  ]

  bucket       = module.s3_bucket.s3_bucket_id
  key          = "bdns.json"
  source       = "${path.module}/bdns.json"
  etag         = md5(local_file.bdns_json.content)
  content_type = "application/json"
}

resource "aws_s3_object" "environment_js" {
  depends_on = [
    local_file.environment_js
  ]

  bucket       = module.s3_bucket.s3_bucket_id
  key          = "environment.js"
  source       = "${path.module}/environment.js"
  etag         = md5(local_file.environment_js.content)
  content_type = "application/javascript; charset=utf-8"
}

resource "aws_s3_object" "html" {
  for_each = fileset("${path.module}/build", "**/*.html")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/build/${each.value}"
  etag         = filemd5("${path.module}/build/${each.value}")
  content_type = "text/html; charset=utf-8"
}

resource "aws_s3_object" "svg" {
  for_each = fileset("${path.module}/build", "**/*.svg")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/build/${each.value}"
  etag         = filemd5("${path.module}/build/${each.value}")
  content_type = "image/svg+xml"
}

resource "aws_s3_object" "css" {
  for_each = fileset("${path.module}/build", "**/*.css")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/build/${each.value}"
  etag         = filemd5("${path.module}/build/${each.value}")
  content_type = "text/css"
}

resource "aws_s3_object" "js" {
  for_each = fileset("${path.module}/build", "**/*.js")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/build/${each.value}"
  etag         = filemd5("${path.module}/build/${each.value}")
  content_type = "application/javascript; charset=utf-8"
}

resource "aws_s3_object" "json" {
  for_each = fileset("${path.module}/build", "**/*.json")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/build/${each.value}"
  etag         = filemd5("${path.module}/build/${each.value}")
  content_type = "application/json"
}

resource "aws_s3_object" "png" {
  for_each = fileset("${path.module}/build", "**/*.png")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/build/${each.value}"
  etag         = filemd5("${path.module}/build/${each.value}")
  content_type = "image/png"
}

resource "aws_s3_object" "jpg" {
  for_each = fileset("${path.module}/build", "**/*.jpg")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/build/${each.value}"
  etag         = filemd5("${path.module}/build/${each.value}")
  content_type = "image/jpg"
}

resource "aws_s3_object" "gif" {
  for_each = fileset("${path.module}/build", "**/*.gif")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/build/${each.value}"
  etag         = filemd5("${path.module}/build/${each.value}")
  content_type = "image/gif"
}

resource "aws_s3_object" "ico" {
  for_each = fileset("${path.module}/build", "**/*.ico")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/build/${each.value}"
  etag         = filemd5("${path.module}/build/${each.value}")
  content_type = "image/x-icon"
}

resource "aws_s3_object" "ttf" {
  for_each = fileset("${path.module}/build", "**/*.ttf")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/build/${each.value}"
  etag         = filemd5("${path.module}/build/${each.value}")
  content_type = "application/octet-stream"
}

resource "aws_s3_object" "manifest" {
  for_each = fileset("${path.module}/build", "**/*.webmanifest")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/build/${each.value}"
  etag         = filemd5("${path.module}/build/${each.value}")
  content_type = "application/manifest+json"
}
