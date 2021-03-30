terraform {
  required_version = ">= 0.13"
  required_providers {
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
    tls = {
      source = "hashicorp/template"
    }
  }
}

