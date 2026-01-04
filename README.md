# terraform-aws-s3-cloudflare-website

A Terraform module to provision a static website with S3 using Cloudflare as a CDN. The Cloudflare configuration qualifies for the [free tier](https://www.cloudflare.com/plans/free/). The bucket policy restricts access to only allow access from Cloudflare.

**Not intended for production use**, but is helpful for serving personal projects for almost free.

> [!CAUTION]
> The Terraform state contains the secret referer value, so `.tfstate` files should not be kept in source control.


## CloudFlare API Token Permission Requirements

* Zone - Single Redirect - Edit
* Zone - Transform Rules - Edit
* Zone - DNS - Edit


## Example Usage

```terraform
provider "aws" {
  region = "us-east-1"
}

provider "cloudflare" {}

locals {
  domain_name        = "trc.yoga"
  cloudflare_zone_id = "47cf5a9c46df3577a53af7589f879732"
}

module "website" {
  source             = "mbbennis/s3-cloudflare-website/aws"
  domain_name        = local.domain_name
  bucket_name        = local.domain_name
  cloudflare_zone_id = local.cloudflare_zone_id
}

# Add module to upload index.html and error.html to the output s3 bucket...
```
