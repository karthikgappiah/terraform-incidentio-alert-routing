terraform {
  required_version = ">= 1.7"

  required_providers {
    incident = {
      source  = "incident-io/incident"
      version = ">= 7.6.1, < 8.0.0"
    }
  }
}
