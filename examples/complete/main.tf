terraform {
  required_version = ">= 1.7"

  required_providers {
    incident = {
      source  = "incident-io/incident"
      version = ">= 7.6.1, < 8.0.0"
    }
  }
}

# The API key comes from the INCIDENT_API_KEY environment variable.
provider "incident" {}

module "alert_routing" {
  source = "../.."

  teams    = yamldecode(file("${path.module}/teams.yaml"))
  services = yamldecode(file("${path.module}/services.yaml"))

  # A Monday, 09:00 Pacific, in the past so the first person is on call now.
  rotation_start        = "2026-10-05T16:00:00Z"
  timezone              = "America/Los_Angeles"
  holiday_country_codes = ["US"]

  alert_source_name      = "Netflix Monitoring"
  route_name             = "Netflix production"
  incident_template_name = "Netflix alert incident"

  # Optional: accumulate the alert's team into this incident custom field.
  affected_teams_custom_field_name = "Affected teams"
}

output "alert_events_url" {
  value = module.alert_routing.alert_events_url
}

output "alert_source_secret_token" {
  value     = module.alert_routing.alert_source_secret_token
  sensitive = true
}
