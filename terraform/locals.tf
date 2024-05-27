# --- locals.tf ---

locals {
  https_url_environment_js_template = "https://raw.githubusercontent.com/${var.gh_repo_name}/${var.gh_repo_ref}/environment.js.template"

  bdns_url = "https://${var.fqdn}/bdns.json"

  csp_frame_src               = "https://pharmaledger.org/"
  csp_frame_src_unsafe_hashes = "sha256-a9WQFev6CZ0GH38JvCWXzczSwvi7wMTbmCWdWaLncC8="

  csp_script_src_unsafe_hashes = "sha256-XkPjGMp0z+c11Qt/zG8pIkC1TIiA9lf9XEXevRQbMTU="

  csp_connect_src = "https://${var.fqdn} ${join(" ", [for url in distinct(regexall("https://[^\"/]+", file(var.bdns_json_file_path))) : url])}"

  s3_object_js   = setsubtract(fileset("${path.module}/LWA", "**/*.js"), ["environment.js", "local_environment.js"])
  s3_object_json = setsubtract(fileset("${path.module}/LWA", "**/*.json"), ["bdns.json", "package.json", "octopus.json", "lib/zxing-wrapper/package.json"])

  cloudfront_default_root_object = "index.html"

  custom_error_response_4xx = flatten([
    for error_code in [400, 403, 404, 405, 414, 416, 500, 501, 502, 503, 504] : [
      {
        error_code            = error_code
        error_caching_min_ttl = 10

        response_code      = error_code
        response_page_path = (error_code == 403 || error_code == 404) ? "/404-errors/index.html" : "/4xx-errors/index.html"
      }
    ]
  ])
}
