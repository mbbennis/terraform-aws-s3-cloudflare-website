variable "domain_name" {
  type        = string
  description = "The domain name for the website"
}

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket to create"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "The Cloudflare Zone ID for the domain"
}

variable "index_object_key" {
  type        = string
  default     = "index.html"
  description = "The key for the index document"
}

variable "error_object_key" {
  type        = string
  default     = "error.html"
  description = "The key for the error document"
}

variable "dns_ttl" {
  type        = number
  default     = 1
  description = "The time to live for the DNS record in seconds (1 is automatic)"
}

