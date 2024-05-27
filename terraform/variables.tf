# ---  7-lwa-app-deployment-pla/variables.tf ---

variable "aws_region" {
  type = string
}

variable "fqdn" {
  type = string
}
variable "dns_domain" {
  type = string
}

variable "epi_domain" {
  type = string
}

variable "app_build_version" {
  type = string
}

variable "bdns_json_file_path" {
  type = string
}

variable "gh_repo_name" {
  type    = string
}
variable "gh_repo_ref" {
  type    = string
}

variable "build_dir_path" {
  type = string
}

variable "time_per_call" {
  type    = number
  default = 10000
}

variable "total_wait_time" {
  type    = number
  default = 60000
}

variable "gto_time_per_call" {
  type    = number
  default = 3000
}

variable "gto_total_wait_time" {
  type    = number
  default = 15000
}

variable "network" {
  type    = string
  default = ""
}
