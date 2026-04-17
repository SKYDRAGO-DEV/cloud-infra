terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "skydrago-terraform-state"
    prefix = "gcp/prod"
  }
}

provider "google" {
  project = var.project_id
  region  = var.gcp_region
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

# VPC Network
resource "google_compute_network" "main" {
  name                    = "skydrago-${var.environment}-vpc"
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "main" {
  name          = "skydrago-${var.environment}-subnet"
  network       = google_compute_network.main.id
  ip_cidr_range = "10.0.0.0/24"
  region        = var.gcp_region

  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Cloud SQL Instance
resource "google_sql_database_instance" "main" {
  name             = "skydrago-${var.environment}-postgres"
  database_version = "POSTGRES_15"
  region           = var.gcp_region

  settings {
    tier              = "db-g1.small"
    availability_type = "REGIONAL"
    disk_size         = 20

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id
    }

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = true
    }
  }
}

# Cloud SQL Database
resource "google_sql_database" "main" {
  name     = "production"
  instance = google_sql_database_instance.main.name
}

# GKE Cluster
resource "google_container_cluster" "main" {
  name               = "skydrago-${var.environment}-gke"
  location           = var.gcp_region
  initial_node_count = 3

  network    = google_compute_network.main.name
  subnetwork = google_compute_subnetwork.main.name

  release_channel {
    channel = "STABLE"
  }

  node_pool {
    name       = "default-pool"
    node_count = 3

    node_config {
      machine_type = "e2-standard-2"
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]
    }
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }
}

# Outputs
output "gke_cluster_name" {
  value = google_container_cluster.main.name
}

output "gke_cluster_endpoint" {
  value = google_container_cluster.main.endpoint
}

output "sql_instance_connection_name" {
  value = google_sql_database_instance.main.connection_name
}
