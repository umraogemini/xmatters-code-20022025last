# This file replaces the versions.tf in every CL repo
terraform {
  required_version = "1.9.8"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.13.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "5.13.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.7.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }

    venafi = {
      source  = "registry.terraform.io/Venafi/venafi"
      version = "0.21.2"
    }

    external = {
      source  = "hashicorp/external"
      version = "2.3.4"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "5.88.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }

    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "2.7.0"
    }

    google-compute = {
      source  = "terraform-google-modules/google-compute"
      version = "1.1.8"
    }

    ansible = {
      source  = "nbering/ansible"
      version = "1.1.3"
    }
  }
}
