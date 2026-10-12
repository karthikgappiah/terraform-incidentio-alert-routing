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
