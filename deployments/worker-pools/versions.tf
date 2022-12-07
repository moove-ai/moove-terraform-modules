terraform {
  required_version = ">=0.13"

  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.42.0, < 5.0"
    }
  }
}