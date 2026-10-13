data "incident_user" "by_email" {
  for_each = local.emails
  email    = each.value
}

# Alert priorities are Catalog entries of the built-in AlertPriority type.
data "incident_catalog_type" "alert_priority" {
  type_name = "AlertPriority"
}

data "incident_catalog_entry" "urgent" {
  catalog_type_id = data.incident_catalog_type.alert_priority.id
  identifier      = var.urgent_priority_name
}

data "incident_alert_attribute" "team" {
  name = var.team_alert_attribute_name
}

data "incident_severity" "by_name" {
  for_each = toset(concat([for b in var.tier_severity : b.severity], [var.default_severity]))
  name     = each.value
}

data "incident_custom_field" "affected_teams" {
  count = var.affected_teams_custom_field_name == null ? 0 : 1
  name  = var.affected_teams_custom_field_name
}
