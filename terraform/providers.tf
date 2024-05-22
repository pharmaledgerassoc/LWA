# ---  7-lwa-app-deployment-pla/providers.tf ---

terraform {
  required_version = "~> 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.17"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }

    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
