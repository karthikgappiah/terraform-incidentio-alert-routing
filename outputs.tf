output "alert_source_id" {
  description = "ID of the HTTP alert source."
  value       = incident_alert_source.source.id
}

output "alert_events_url" {
  description = "URL monitoring tools post alerts to. Send the secret token as a bearer token."
  value       = incident_alert_source.source.alert_events_url
}

output "alert_source_secret_token" {
  description = "Bearer token for alert_events_url."
  value       = incident_alert_source.source.secret_token
  sensitive   = true
}

output "alert_route_id" {
  description = "ID of the one alert route."
  value       = incident_alert_route.this.id
}

output "team_catalog_entry_ids" {
  description = "Catalog entry ID of each team, keyed as in var.teams."
  value       = { for k, e in incident_catalog_entries.team.entries : k => e.id }
}

output "schedule_ids" {
  description = "On-call schedule ID of each team, keyed as in var.teams."
  value       = { for k, s in incident_schedule.team : k => s.id }
}

output "escalation_path_ids" {
  description = "Escalation path ID of each team, keyed as in var.teams. The backstop team's path is its own."
  value = merge(
    { for k, p in incident_escalation_path.team : k => p.id },
    { (local.backstop_team) = incident_escalation_path.backstop.id },
  )
}
