# -----------------------
# CloudFront Origin Access Control for S3
# -----------------------
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3-oac-${var.env}"
  description                       = "Allow CloudFront access to S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# -----------------------
# CloudFront Distribution (only S3)
# -----------------------
resource "aws_cloudfront_distribution" "cdn" {
  enabled             = true
  default_root_object = "index.html"

  # -----------------------
  # S3 origin
  # -----------------------
  origin {
    domain_name = var.s3_bucket_domain
    origin_id   = "s3-origin"

    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  # -----------------------
  # Default cache behavior (S3)
  # -----------------------
  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # -----------------------
  # No API ordered cache behavior
  # -----------------------
  # (Removed everything related to /api/*)

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# -----------------------
# S3 bucket policy for CloudFront
# -----------------------
resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = replace(var.s3_bucket_arn, "arn:aws:s3:::", "")

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:GetObject"
        Resource = "${var.s3_bucket_arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
          }
        }
      }
    ]
  })
}

# -----------------------
# Remove CloudFront function (no API rewrite needed)
# -----------------------
# (Delete the aws_cloudfront_function.api_rewrite resource)