data "google_container_registry_repository" "policy_as_code" {}

# This may incur a small cost to run!
resource "google_cloud_run_service" "policy_as_code" {
  name     = "policy-as-code"
  location = "us-central1"

  template {
    spec {
      containers {
        image   = "${data.google_container_registry_repository.policy_as_code.repository_url}/${var.image_name}"
        command = ["/usr/local/bin/fake-service"]
        ports {
          container_port = 9090
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}