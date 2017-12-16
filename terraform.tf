variable "project_name" {}
variable "aws_region" {
  default = "eu-west-1"
}

# AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
provider "aws" {
  region = "${var.aws_region}"
}

# HEROKU_API_KEY, HEROKU_EMAIL
provider "heroku" {

}

# Store Terraform state in S3 (this must be prepared in advance)
terraform {
  backend "s3" {
    bucket = "wp-base-upload"
    key = "wp/terraform.tfstate"
    region = "eu-west-1"
  }
}

# IAM user for S3 bucket
resource "aws_iam_user" "dev" {
  name = "${var.project_name}-dev-user"
}

# Access keys for IAM user
resource "aws_iam_access_key" "dev" {
  user = "${aws_iam_user.dev.name}"
}

# S3 bucket for uploads
resource "aws_s3_bucket" "dev" {
  bucket = "${var.project_name}-dev-uploads"
  acl = "public-read"
  force_destroy = "true"
}

# Grant full access to the bucket
resource "aws_s3_bucket_policy" "dev" {
  bucket = "${aws_s3_bucket.dev.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_user.dev.arn}"
      },
      "Action": [ "s3:*" ],
      "Resource": [
        "${aws_s3_bucket.dev.arn}",
        "${aws_s3_bucket.dev.arn}/*"
      ]
    }
  ]
}
EOF
}

# Heroku App
resource "heroku_app" "dev" {
  name = "${var.project_name}-dev"
  region = "eu"
  buildpacks = [
    "heroku/php",
    "heroku/nodejs"
  ]
  config_vars {
    WP_ENV = "dev"
    S3_UPLOADS_BUCKET = "${aws_s3_bucket.dev.id}"
    S3_UPLOADS_KEY = "${aws_iam_access_key.dev.id}"
    S3_UPLOADS_SECRET = "${aws_iam_access_key.dev.secret}"
    S3_UPLOADS_REGION = "${var.aws_region}"
  }
}

# Heroku Redis
resource "heroku_addon" "redis-dev" {
  app = "${heroku_app.dev.name}"
  plan = "heroku-redis:hobby-dev"
}

# Heroku Papertrail
resource "heroku_addon" "papertrail-dev" {
  app = "${heroku_app.dev.name}"
  plan = "papertrail:choklad"
}

# Outputs
output "heroku git remote" {
  value = "${heroku_app.dev.git_url}"
}

