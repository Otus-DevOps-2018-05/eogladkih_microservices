
terraform {
  backend "gcs" {
    bucket = "storage-bucket-215010"
    prefix = "name"
  }
}
