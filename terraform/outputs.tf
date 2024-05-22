# ---  7-lwa-app-deployment-pla/outputs.tf ---

output "cloudfront_distribution_id" {
  value = module.cloudfront.cloudfront_distribution_id
}
