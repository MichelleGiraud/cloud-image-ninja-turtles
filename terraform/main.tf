provider "google" {
  project = "ingka-native-ikealabs-dev"
  region  = "europe-west1"
}

module "cint_upload_bucket" {
  source      = "./module/bucket"
  bucket_name = "cint_upload_bucket"
}

module "cint_clean_bucket" {
  source      = "./module/bucket"
  bucket_name = "cint_clean_bucket"
}

resource "google_artifact_registry_repository" "cint_repo" {
  repository_id = "cint-repo"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_binding" "cint_repo_binding" {
  location   = google_artifact_registry_repository.cint_repo.location
  repository = google_artifact_registry_repository.cint_repo.name
  role       = "roles/artifactregistry.admin"
  members = [
    "user:sally.erisman@ingka.ikea.com",
    "user:zack.fitz-gibbon.jeppesen1@ingka.ikea.com",
    "user:michelle.giraud@ingka.ikea.com",
    "user:pernilla.lundahl@ingka.ikea.com",
  ]
}

//Creates a Cloud Run service
resource "google_cloud_run_v2_service" "cint_cloud_run" {
  name     = "cint-cloud-run"
  location = var.location
  template {
    containers {
      # image = "europe-west1-docker.pkg.dev/ingka-native-ikealabs-dev/cint-repo/cint-my-docker-image:latest"
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
    service_account = google_service_account.cint_sa.email
    //environment_variables = {
    //AUTH_API_KEY = "AIzaSyA0m2e3o7WP73TAFIA9UPDLjDORlzhR4HE"
    //}
  }
}


//PubSub

//Creates pub/sub topic "cint_topic"
resource "google_pubsub_topic" "cint_topic" {
  name = "cint_topic"
}

//Right now has a lot of permissions maybe look into roles/pubsub.topic.____ instead of admin
resource "google_pubsub_topic_iam_binding" "cint_topic_binding" {
  topic   = google_pubsub_topic.cint_topic.name
  role    = "roles/pubsub.admin"
  members = ["serviceAccount:${google_service_account.cint_sa.email}"]
}

//Creates pub/sub subcripition "cint_subscription" TO-DO
resource "google_pubsub_subscription" "cint_subscription" {
  name  = "cint_subscription"
  topic = "cint_topic"
  push_config {
    push_endpoint = google_cloud_run_v2_service.cint_cloud_run.uri
    oidc_token {
      service_account_email = google_service_account.cint_sa.email
    }
  }
  depends_on = [google_cloud_run_v2_service.cint_cloud_run]
}

//Creates a Google Service Account
resource "google_service_account" "cint_sa" {
  account_id   = "cint-cloud-run-pubsub-invoker"
  display_name = "CINT Cloud Run Pub/Sub Invoker"
}

//Binds the Cloud Run service to the Service Account
resource "google_cloud_run_service_iam_binding" "cint_service_binding" {
  location = google_cloud_run_v2_service.cint_cloud_run.location
  service  = google_cloud_run_v2_service.cint_cloud_run.name
  role     = "roles/run.admin"
  members  = ["serviceAccount:${google_service_account.cint_sa.email}"]
}

resource "google_storage_bucket_iam_binding" "cint_storage_permissions" {
  for_each = {
    "bucket1" = module.cint_upload_bucket.bucket_name,
    "bucket2" = module.cint_clean_bucket.bucket_name
  }
  bucket  = each.value
  role    = "roles/storage.admin"
  members = ["serviceAccount:${google_service_account.cint_sa.email}"]
}

resource "google_project_service_identity" "cint_pubsub_agent" {
  provider = google-beta
  project  = var.project_name
  service  = "pubsub.googleapis.com"
}

resource "google_project_iam_binding" "cint_project_token_creator" {
  project = var.project_name
  role    = "roles/iam.serviceAccountTokenCreator"
  members = ["serviceAccount:${google_project_service_identity.cint_pubsub_agent.email}"]
}

//PubSub notification

// Create a Pub/Sub notification.
resource "google_storage_notification" "cint_notification" {
  provider       = google-beta
  bucket         = module.cint_upload_bucket.bucket_name
  event_types    = ["OBJECT_FINALIZE"] # Trigger when a new object is created
  payload_format = "JSON_API_V1"
  topic          = google_pubsub_topic.cint_topic.id
  depends_on     = [google_pubsub_topic_iam_binding.cint_topic_binding]
}

