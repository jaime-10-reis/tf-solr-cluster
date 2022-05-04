resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name

  # AWS Educate does not allow object lock
  #object_lock_enabled = true

  #  Carefully consider the following block; not a good idea in a production environment
  force_destroy = true
  lifecycle {
    prevent_destroy = false
  }

}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

/* AWS Educate does not allow object lock
resource "aws_s3_bucket_object_lock_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.bucket

  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = 5
    }
  }
}
*/ 

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  block_public_acls = true
  block_public_policy = true
  bucket = aws_s3_bucket.terraform_state.bucket
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}