# ---  7-lwa-app-deployment-pla/s3_objects.tf ---

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
  for_each = fileset("${path.module}/LWA", "**/*.html")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/LWA/${each.value}"
  etag         = filemd5("${path.module}/LWA/${each.value}")
  content_type = "text/html; charset=utf-8"
}

resource "aws_s3_object" "svg" {
  for_each = fileset("${path.module}/LWA", "**/*.svg")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/LWA/${each.value}"
  etag         = filemd5("${path.module}/LWA/${each.value}")
  content_type = "image/svg+xml"
}

resource "aws_s3_object" "css" {
  for_each = fileset("${path.module}/LWA", "**/*.css")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/LWA/${each.value}"
  etag         = filemd5("${path.module}/LWA/${each.value}")
  content_type = "text/css"
}

resource "aws_s3_object" "js" {
  for_each = local.s3_object_js

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/LWA/${each.value}"
  etag         = filemd5("${path.module}/LWA/${each.value}")
  content_type = "application/javascript; charset=utf-8"
}

resource "aws_s3_object" "json" {
  for_each = local.s3_object_json

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/LWA/${each.value}"
  etag         = filemd5("${path.module}/LWA/${each.value}")
  content_type = "application/json"
}

resource "aws_s3_object" "png" {
  for_each = fileset("${path.module}/LWA", "**/*.png")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/LWA/${each.value}"
  etag         = filemd5("${path.module}/LWA/${each.value}")
  content_type = "image/png"
}

resource "aws_s3_object" "jpg" {
  for_each = fileset("${path.module}/LWA", "**/*.jpg")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/LWA/${each.value}"
  etag         = filemd5("${path.module}/LWA/${each.value}")
  content_type = "image/jpg"
}

resource "aws_s3_object" "gif" {
  for_each = fileset("${path.module}/LWA", "**/*.gif")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/LWA/${each.value}"
  etag         = filemd5("${path.module}/LWA/${each.value}")
  content_type = "image/gif"
}

resource "aws_s3_object" "ico" {
  for_each = fileset("${path.module}/LWA", "**/*.ico")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/LWA/${each.value}"
  etag         = filemd5("${path.module}/LWA/${each.value}")
  content_type = "image/x-icon"
}

resource "aws_s3_object" "ttf" {
  for_each = fileset("${path.module}/LWA", "**/*.ttf")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/LWA/${each.value}"
  etag         = filemd5("${path.module}/LWA/${each.value}")
  content_type = "application/octet-stream"
}

resource "aws_s3_object" "manifest" {
  for_each = fileset("${path.module}/LWA", "**/*.webmanifest")

  bucket       = module.s3_bucket.s3_bucket_id
  key          = each.value
  source       = "${path.module}/LWA/${each.value}"
  etag         = filemd5("${path.module}/LWA/${each.value}")
  content_type = "application/manifest+json"
}