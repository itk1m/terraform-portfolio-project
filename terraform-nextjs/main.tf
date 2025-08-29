provider "aws" {
  region = "us-east-1"
}

#S3 Bucket
resource "aws_s3_bucket" "website"{
    bucket = "nextjs-portfolio-bucket-ik"
}

# Ownership Control
resource "aws_s3_bucket_ownership_controls" "nextjs_bucket_ownership_controls" {
  bucket = aws_s3_bucket.nextjs_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "nextjs_bucket_public_access_block" {
    bucket = aws_s3_bucket.nextjs_bucket.id

    block_public_acls = false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false 
}

#Bucket ACL
resource "aws_s3_bucket_acl" "nextjs_bucket_acl" {

  depends_on = [ 
    aws_s3_bucket_ownership_controls.nextjs,
    aws_s3_bucket_public_access_block.nextjs_bucket_public_access_block 
   ]

   bucket = aws_s3_bucket.nextjs_bucket.id
   acl = "public-read"
}

# Bucket policy
resource "aws_s3_bucket_policy" "nextjs_bucket_policy" {
    bucket = aws_s3_bucket.nextjs_bucket.id
    #Purpose of the policy is to allow the public to access anything in the bucket
    policy = jsondecode({
        Version = "2012-09-07"
        Statement = [
            {   # rules
                Sid = "PublicReadGetObject"
                Effect = "Allow"
                Principal = "*" # the * means for all users
                Action = "s3:GetObject"
                Resource = "${aws_s3_bucket.nextjs_bucket.arn}/*"
            }
        ]
    })
}

# Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "OAI(Origin Access Identity) for Next.JS portfolio site "
}

# Cloudfront 
resource "aws_cloudfront_distribution" "website_distribution" {
    
    origin {
        domain_name = aws_s3_bucket.nextjs_bucket.bucket_regional_domain_name
        origin_id = "S3-nextjs-portfolio-bucket"
    
        s3_origin_config {
          origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
        }
    }

    enabled = true
    is_ipv6_enabled = true
    comment = "Next.js Portflio site"
    default_root_object = "index.html"

    default_cache_behavior {
      allowed_methods = ["GET","HEAD","OPTIONS"]
      cached_methods = ["GET","HEAD"]
      target_origin_id = "S3-nextjs-protfolio-bucket"
    
       forwarded_values {
         query_string = false
         cookies {
           forward = "none"
         }
       }

      viewer_protocol_policy = "redirect-to-https"
      min_ttl = 0 # minimum amount of time for an object to cache in minutes
      default_ttl = 3600 # a whole entire day
      max_ttl = 86400
    }

    restrictions {
      geo_restriction {
        restriction_type = "none"
      }
    }

    viewer_certificate {
      cloudfront_default_certificate = true
    }

    tags = {
        Name = "Portfolio Certificate"
        Environment = "Production"
    }
}