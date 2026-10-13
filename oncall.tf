# One schedule and one weekly rotation per team in var.teams.

resource "incident_schedule" "team" {
  for_each = var.teams

  name     = "${each.value.name} on-call"
  timezone = var.timezone
  team_ids = [incident_catalog_entries.team.entries[each.key].id]

  holidays_public_config = length(var.holiday_country_codes) > 0 ? {
    country_codes = var.holiday_country_codes
  } : null
}

resource "incident_schedule_rotation" "team" {
  for_each = var.teams

  schedule_id              = incident_schedule.team[each.key].id
  name                     = "Rotation"
  users                    = [for e in each.value.on_call : data.incident_user.by_email[e].id]
  first_interval_starts_at = var.rotation_start
  concurrent_shifts        = 1

  handovers = [{
    interval      = 1
    interval_type = "weekly"
  }]
}
