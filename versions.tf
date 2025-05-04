# This file replace the versions.tf in every CL repo
terraform {
  required_version = ">= 1.9.8"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.11.2"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "6.11.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.6.0"
    }
    venafi = {
      source  = "registry.terraform.io/Venafi/venafi"
      version = "0.21.1"
    }
  }
}
