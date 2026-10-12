# The Catalog: who owns what. Alerts are matched to these entries, and the
# route reads the owning team's escalation path from them.

resource "incident_catalog_type" "team" {
  name                   = "Team"
  description            = var.team_type_description
  categories             = ["team"]
  type_name              = "Custom[\"Team\"]"
  source_repo_url        = ""
  use_name_as_identifier = true
}

resource "incident_catalog_type" "service" {
  name                   = "Service"
  description            = var.service_type_description
  categories             = ["service"]
  type_name              = "Custom[\"Service\"]"
  source_repo_url        = ""
  use_name_as_identifier = true
}

resource "incident_catalog_type_attribute" "service_owner" {
  catalog_type_id = incident_catalog_type.service.id
  name            = "Owner"
  type            = incident_catalog_type.team.type_name
  array           = false
  schema_only     = true
}

resource "incident_catalog_type_attribute" "service_tier" {
  catalog_type_id = incident_catalog_type.service.id
  name            = "Tier"
  type            = "String"
  array           = false
  schema_only     = true
}

resource "incident_catalog_type_attribute" "service_lifecycle" {
  catalog_type_id = incident_catalog_type.service.id
  name            = "Lifecycle"
  type            = "String"
  array           = false
  schema_only     = true
}

# Terraform owns team names, aliases and members. The "Escalation paths"
# attribute is filled in by incident.io from each path's team, so it is
# left out of managed_attributes.
resource "incident_catalog_entries" "team" {
  id                 = incident_catalog_type.team.id
  managed_attributes = ["members"]

  entries = {
    for k, t in var.teams : k => {
      name    = t.name
      aliases = t.aliases
      attribute_values = {
        members = {
          array_value = [for e in t.members : data.incident_user.by_email[e].id]
        }
      }
    }
  }
}

resource "incident_catalog_entries" "service" {
  id = incident_catalog_type.service.id

  # A service's owner must exist before the service can point at it.
  depends_on = [incident_catalog_entries.team]

  entries = {
    for k, s in var.services : k => {
      name    = k
      aliases = s.aliases
      attribute_values = merge(
        {
          (incident_catalog_type_attribute.service_owner.id)     = { value = s.owner }
          (incident_catalog_type_attribute.service_lifecycle.id) = { value = s.lifecycle }
        },
        s.tier != null ? { (incident_catalog_type_attribute.service_tier.id) = { value = s.tier } } : {},
      )
    }
  }

  lifecycle {
    precondition {
      condition     = alltrue([for s in var.services : contains(keys(var.teams), s.owner)])
      error_message = "Every service owner must be a key of var.teams."
    }
  }
}
