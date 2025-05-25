provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "Your GCP project ID"
  type        = string
}

variable "project_number" {
  description = "Your GCP project number"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "github_repo" {
  description = "Your GitHub repository in the format 'owner/repo'"
  type        = string
}

resource "google_iam_workload_identity_pool" "wif-github-pool" {
  workload_identity_pool_id = "wif-github-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Pool for GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "wif-github-provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.wif-github-pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-wif-provider"
  display_name                       = "GitHub Actions Provider"
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }
  attribute_condition = "attribute.repository == '${var.github_repo}'"
}

resource "google_service_account" "github_actions_sa" {
  account_id   = "github-actions-sa"
  display_name = "Service Account for GitHub Actions"
}

resource "google_project_iam_member" "sa_permissions" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}

resource "google_service_account_iam_binding" "workload_identity_binding" {
  service_account_id = google_service_account.github_actions_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.wif-github-pool.workload_identity_pool_id}/*"
  ]
}
