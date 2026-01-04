terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.27"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 5.15"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7"
    }
  }
}

