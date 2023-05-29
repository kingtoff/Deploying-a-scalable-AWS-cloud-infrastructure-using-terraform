# S3 Bucket for State File
resource "aws_s3_bucket" "states-bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "states_bucket_versioning" {
  bucket = aws_s3_bucket.states-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "states_encrpt_config" {
  bucket = aws_s3_bucket.states-bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Dynamo DB Table for Locking TF Config
resource "aws_dynamodb_table" "states_locks_DB" {
  name         = "DB-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
