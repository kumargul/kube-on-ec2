variable "environment" {
  description = "Name of the Environment"
  default     = "dev"
}

variable "dynamo_db_table_name" {
  description = "Name of DynamoDB table used for State locking"
}
variable "s3_tfstate_bucket" {
  description = "Name of S3 bucket used for storing TF State files"
}
