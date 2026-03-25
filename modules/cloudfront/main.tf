resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3-oac"
  description                       = "Allow CloudFront access to S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

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
  # API Gateway origin
  # -----------------------
  origin {
    domain_name = replace(var.api_gateway_endpoint, "https://", "")
    origin_id   = "api-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
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
  # Ordered cache behavior (API)
  # -----------------------
  ordered_cache_behavior {
    path_pattern           = "/api/*"
    target_origin_id       = "api-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET","HEAD","OPTIONS","PUT","POST","PATCH","DELETE"]
    cached_methods  = ["GET","HEAD"]

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    # -----------------------
    # Function for path rewrite
    # -----------------------
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.api_rewrite.arn
    }
  }

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
# CloudFront function for API rewrite
# -----------------------
resource "aws_cloudfront_function" "api_rewrite" {
  name    = "dev-api-path-rewrite"
  runtime = "cloudfront-js-1.0"

  code = <<EOF
function handler(event) {
    var request = event.request;
    if (request.uri.startsWith("/api")) {
        // prepend /dev to match API Gateway stage
        request.uri = "/dev" + request.uri.replace(/^\\/api/, "");
    }
    return request;
}
EOF
}

# -----------------------
# S3 bucket policy
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