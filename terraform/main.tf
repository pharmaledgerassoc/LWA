# --- main.tf ---

data "aws_route53_zone" "main" {
  name         = var.dns_domain
  private_zone = false
}

resource "local_file" "bdns_json" {
  filename = "${path.module}/bdns.json"

  content = file(local.bdns_json_local_path)
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
