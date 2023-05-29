variable "bucket_name" {
  description = "the name given to our bucket storing our states remotely"
  type        = string
  validation {
    condition     = can(regex("^([a-z0-9]{1}[a-z0-9-]{1,61}[a-z0-9]{1})$", var.bucket_name))
    error_message = "Bucket name must be between 3 and 63 characters long, contain only lowercase letters, numbers, hyphens, and not begin or end with a hyphen."
  }
}