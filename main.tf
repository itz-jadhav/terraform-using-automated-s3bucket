resource "aws_s3_bucket" "kunalbucket" {
  bucket = var.bucketname
}

resource "aws_s3_bucket_ownership_controls" "kunalbucket" {
  bucket = aws_s3_bucket.kunalbucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "kunalbucket" {
  bucket = aws_s3_bucket.kunalbucket.id

  block_public_acls       = false  # Ensure this is false
  block_public_policy     = false  # Ensure this is false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "kunalbucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.kunalbucket,
    aws_s3_bucket_public_access_block.kunalbucket,
  ]

  bucket = aws_s3_bucket.kunalbucket.id
  acl    = "public-read"
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.kunalbucket.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.kunalbucket.id
  key          = "error.html"
  source       = "error.html"
  content_type = "text/html"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.kunalbucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "kunalbucket_policy" {
  bucket = aws_s3_bucket.kunalbucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "s3:GetObject"
        Effect    = "Allow"
        Resource  = "${aws_s3_bucket.kunalbucket.arn}/*"
        Principal = "*"
      }
    ]
  })
}
