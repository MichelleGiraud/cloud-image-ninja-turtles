provider "google" {
  project = "ingka-native-ikealabs-dev"
  region  = "europe-west1"
}

module "cint_upload_bucket" {
  source      = "./module/bucket"
  bucket_name = "cint_upload_bucket"
}
