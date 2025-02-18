terraform {
  backend "s3" {}
}

provider "aws" {
  region = "ap-southeast-2"
  default_tags {
    tags = {
      env   = var.environment
      owner = "testingGK"
    }
  }
}

resource "aws_dynamodb_table" "tf_lock_state" {
  name         = var.dynamo_db_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name      = var.dynamo_db_table_name
    Terraform = "true"
  }
}

resource "aws_s3_bucket" "state_bucket" {
  bucket = var.s3_tfstate_bucket

  tags = {
    Terraform = "true"
  }
}

resource "aws_s3_bucket_versioning" "state_bucket_version" {
  bucket = aws_s3_bucket.state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket_encryption" {
  bucket = aws_s3_bucket.state_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "state_bucket" {
  bucket = aws_s3_bucket.state_bucket.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowSSLRequestsOnly",
        "Action" : "s3:*",
        "Effect" : "Deny",
        "Resource" : [
          aws_s3_bucket.state_bucket.arn,
          "${aws_s3_bucket.state_bucket.arn}/*"
        ],
        "Condition" : {
          "Bool" : {
            "aws:SecureTransport" : "false"
          }
        },
        "Principal" : "*"
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "state_bucket" {
  bucket = aws_s3_bucket.state_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
