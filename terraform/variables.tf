# ---  7-lwa-app-deployment-pla/variables.tf ---

variable "aws_region" {
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

variable "network_name" {
  type    = string
  default = ""
}

variable "bdns_json_url" {
  type    = string
  default = ""
}

variable "hostname" {
  type    = string
  default = ""
}

variable "lwa_repo" {
  type    = string
  default = ""
}

variable "lwa_branch" {
  type    = string
  default = ""
}
