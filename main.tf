data "cloudflare_ip_ranges" "cloudflare" {}

resource "random_password" "origin_secret" {
  length  = 32
  special = false
  keepers = {
    token_trigger = var.domain_name
  }
}

resource "aws_s3_bucket" "website" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "website_configuration" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = var.index_object_key
  }

  error_document {
    key = var.error_object_key
  }
}

data "aws_iam_policy_document" "allow_access_from_cloudflare" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:Referer"
      values   = [random_password.origin_secret.result]
    }

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = data.cloudflare_ip_ranges.cloudflare.ipv4_cidrs
    }
  }
}

resource "aws_s3_bucket_public_access_block" "website_public_access_block" {
  bucket                  = aws_s3_bucket.website.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudflare.json
  depends_on = [
    aws_s3_bucket_public_access_block.website_public_access_block
  ]
}

resource "cloudflare_dns_record" "website" {
  type    = "CNAME"
  zone_id = var.cloudflare_zone_id
  name    = var.domain_name
  ttl     = var.dns_ttl
  content = aws_s3_bucket_website_configuration.website_configuration.website_endpoint
  proxied = true
}

resource "cloudflare_dns_record" "website" {
  type    = "CNAME"
  zone_id = var.cloudflare_zone_id
  name    = "www"
  ttl     = var.dns_ttl
  content = var.domain_name
  proxied = true
}

resource "cloudflare_ruleset" "redirect_www_to_non_www" {
  zone_id = var.cloudflare_zone_id
  name    = "redirects"
  kind    = "zone"
  phase   = "http_request_dynamic_redirect"

  rules = [
    {
      description = "Redirect www to root"
      expression  = "http.host == \"www.${var.domain_name}\""
      action      = "redirect"
      action_parameters = {
        from_value = {
          status_code = 301
          target_url = {
            expression = "concat(\"https://${var.domain_name}\", http.request.uri.path)"
          }
          preserve_query_string = true
        }
      }
    }
  ]
}

resource "cloudflare_ruleset" "add_referer_header" {
  zone_id = var.cloudflare_zone_id
  name    = "header transformations"
  kind    = "zone"
  phase   = "http_request_late_transform"

  rules = [
    {
      description = "Add referer header"
      expression  = "true"
      action      = "rewrite"
      action_parameters = {
        headers = {
          "Referer" = {
            operation = "set"
            value     = random_password.origin_secret.result
          }
        }
      }
    }
  ]
}

