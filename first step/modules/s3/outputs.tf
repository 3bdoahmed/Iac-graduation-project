output "source_buckets" {
  value = [
    for bucket in aws_s3_bucket.source_buckets :
    bucket.bucket
  ]
}

output "monitoring_bucket" {
  value = aws_s3_bucket.monitoring_bucket.bucket
}