resource "aws_s3_bucket" "source_buckets" {
  for_each = toset([
    "batteries-data-2026",
    "panels-data-2026"
  ])

  bucket = each.value
}

resource "aws_s3_bucket" "monitoring_bucket" {
  bucket = "montering-data-2026"
}