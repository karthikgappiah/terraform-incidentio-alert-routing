# One route for every team. It never names a team: it follows the alert's
# Team to that team's escalation path, and falls back to the backstop team.
resource "incident_alert_route" "this" {
  name            = var.route_name
  enabled         = true
  is_private      = false
  owning_team_ids = [incident_catalog_entries.team.entries[local.backstop_team].id]

  alert_sources = [{
    alert_source_id  = incident_alert_source.source.id
    condition_groups = []
  }]
  condition_groups = []

  expressions = [{
    label          = "Alert → Attributes → Team  → Escalation paths"
    reference      = "01M4N8BWY2C6H2S6JD6EKCTC9F"
    root_reference = "alert.attributes.${data.incident_alert_attribute.team.id}"
    operations = [{
      operation_type = "navigate"
      navigate       = { reference = "catalog_attribute[\"escalation_paths\"]" }
    }]
    else_branch = {
      result = { array_value = [{ literal = incident_escalation_path.backstop.id }] }
    }
  }]

  escalation_config = {
    auto_cancel_escalations = true
    escalation_targets = [{
      escalation_paths = {
        array_value = [{ reference = "expressions[\"01M4N8BWY2C6H2S6JD6EKCTC9F\"]" }]
      }
    }]
    when_alert_joins_group = { mode = "on_priority_increase" }
  }

  # One incident per Service per window; each new alert extends it.
  grouping_config = {
    default = {
      enabled        = true
      ai_enabled     = false
      grouping_keys  = [{ reference = "alert.attributes.${incident_alert_attribute.service.id}" }]
      window_seconds = var.grouping_window_seconds
      window_type    = "rolling"
    }
  }

  # Only the urgent priority and above open an incident.
  incident_config = {
    enabled              = true
    auto_decline_enabled = true
    condition_groups = [{
      conditions = [{
        subject        = "alert.priority"
        operation      = "gte"
        param_bindings = [{ value = { literal = data.incident_catalog_entry.urgent.id } }]
      }]
    }]
    incident_template = {
      value = { literal = incident_incident_template.alert_incident.id }
    }
  }

  message_config = {}
}
