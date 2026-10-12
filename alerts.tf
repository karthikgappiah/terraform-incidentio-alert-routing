# Where alerts come in and what we read from them. The route that sends them
# on is in routing.tf.

resource "incident_alert_source" "source" {
  name                         = var.alert_source_name
  source_type                  = "http"
  is_private                   = false
  auto_resolve_incident_alerts = true

  title       = { literal = "{{title}}" }
  description = { literal = "{{description}}" }

  # Priority comes from metadata.severity, matched against the alert
  # priorities. Anything unrecognised is treated as Urgent.
  priority = { expression_ref = "71fdf6d6" }

  named_expression {
    name       = "71fdf6d6"
    label      = "Priority"
    start_from = "payload"
    operation {
      parse = {
        function = "$.metadata.severity"
        as       = "CatalogEntry[\"AlertPriority\"]"
      }
    }
    fallback {
      result = { value_literal = data.incident_catalog_entry.urgent.id }
    }
  }
}

resource "incident_alert_attribute" "service" {
  name     = "Service"
  type     = "CatalogEntry[\"${incident_catalog_type.service.id}\"]"
  array    = false
  required = false
}

resource "incident_alert_attribute" "runbook" {
  name     = "Runbook"
  type     = "String"
  array    = false
  required = false
}

# Service: metadata.service, matched against the Service Catalog.
resource "incident_alert_source_attribute" "service" {
  alert_source_id    = incident_alert_source.source.id
  alert_attribute_id = incident_alert_attribute.service.id
  merge_strategy     = "first_wins"
  expression_ref     = "880f720d"

  named_expression {
    name       = "880f720d"
    label      = "Service"
    start_from = "payload"
    operation {
      parse = {
        function = "$.metadata.service"
        as       = incident_alert_attribute.service.type
      }
    }
  }
}

# Team: metadata.team_owner, matched against the Team Catalog (names or
# aliases). If that's missing or unknown, fall back to the service's Owner.
resource "incident_alert_source_attribute" "team" {
  alert_source_id    = incident_alert_source.source.id
  alert_attribute_id = data.incident_alert_attribute.team.id
  merge_strategy     = "first_wins"
  expression_ref     = "eda36efa"

  named_expression {
    name       = "5e5b6d41"
    label      = "expression-5e5b6d41"
    start_from = "payload"
    operation {
      parse = {
        function = "$.metadata.service"
        as       = incident_alert_attribute.service.type
      }
    }
    operation {
      navigate = { to = incident_catalog_type_attribute.service_owner.id }
    }
  }

  named_expression {
    name       = "eda36efa"
    label      = "Team"
    start_from = "payload"
    operation {
      parse = {
        function = "$.metadata.team_owner"
        as       = "CatalogEntry[\"${incident_catalog_type.team.id}\"]"
      }
    }
    fallback {
      expression_ref = "5e5b6d41"
    }
  }
}

resource "incident_alert_source_attribute" "runbook" {
  alert_source_id    = incident_alert_source.source.id
  alert_attribute_id = incident_alert_attribute.runbook.id
  merge_strategy     = "first_wins"
  expression_ref     = "44cb4383"

  named_expression {
    name       = "44cb4383"
    label      = "Runbook"
    start_from = "payload"
    operation {
      parse = {
        function = "$.metadata.runbook_url"
        as       = "String"
      }
    }
  }
}
