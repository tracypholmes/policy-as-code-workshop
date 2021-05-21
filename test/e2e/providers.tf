terraform {
  required_version = "~>0.15"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.66"
    }
  }
}

provider "google" {}

resource "google_project_service" "cloud_run" {
  service = "run.googleapis.com"

  disable_dependent_services = true
}