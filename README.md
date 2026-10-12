# terraform-incidentio-alert-routing

[![CI](https://github.com/karthikgappiah/terraform-incidentio-alert-routing/actions/workflows/ci.yml/badge.svg)](https://github.com/karthikgappiah/terraform-incidentio-alert-routing/actions/workflows/ci.yml)

Terraform module for incident.io alert routing driven by the Catalog. Give it your teams and your services and it builds one alert source, one dynamic route, an escalation path per team and the incident template, so onboarding a team is a data change.

A worked consumer of this module is [terraform-incidentio-appiahco](https://github.com/karthikgappiah/terraform-incidentio-appiahco).

## What it builds

```
HTTP alert source
  Team     ← metadata.team_owner, else the Service's Owner
  Service  ← metadata.service
  Priority ← metadata.severity, unknown means Urgent
        │
        ▼
one route: Alert → Team → Escalation paths, else the backstop team's path
        │
        ├─ path     Urgent: team on-call at high urgency, then the backstop team
        │           lower:  team on-call at low urgency
        └─ incident Urgent only; severity from the Service's Tier; one per Service per window
```

Per team in `var.teams` you get a Catalog entry, an on-call schedule with a weekly rotation and an escalation path. Per service in `var.services` you get a Catalog entry with Owner, Tier and Lifecycle.

## Usage

```hcl
module "alert_routing" {
  source = "github.com/karthikgappiah/terraform-incidentio-alert-routing?ref=v0.1.1"

  teams    = yamldecode(file("${path.module}/teams.yaml"))
  services = yamldecode(file("${path.module}/services.yaml"))

  rotation_start = "2026-10-05T16:00:00Z" # a Monday, in the past
  timezone       = "America/Los_Angeles"
}
```

```yaml
# teams.yaml
sre:
  name: SRE
  members: [oncall@example.com]
  on_call: [oncall@example.com]
  backstop: true
streaming:
  name: Streaming
  aliases: [streaming-infrastructure]
  members: [oncall@example.com]
  on_call: [oncall@example.com]
```

```yaml
# services.yaml
video-transcoding-service:
  owner: streaming
  tier: tier-1
  lifecycle: production
```

A complete call is in [examples/complete](examples/complete). The provider reads `INCIDENT_API_KEY` from the environment of whoever calls the module.

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `teams` | map(object) | required | Teams keyed by Catalog external ID. Exactly one has `backstop = true` |
| `services` | map(object) | required | Services keyed by `metadata.service`; `owner` is a key of `teams` |
| `rotation_start` | string | required | RFC 3339 start of the first weekly shift |
| `timezone` | string | `"UTC"` | Timezone of schedules and working hours |
| `holiday_country_codes` | list(string) | `[]` | Public holidays shown on schedules |
| `alert_source_name` | string | `"Alert routing"` | Name of the HTTP alert source |
| `route_name` | string | `"Alert routing"` | Name of the route |
| `incident_template_name` | string | `"Alert incident"` | Name of the incident template |
| `team_type_description` | string | generic | Description of the Team Catalog type |
| `service_type_description` | string | generic | Description of the Service Catalog type |
| `urgent_priority_name` | string | `"Urgent"` | The priority that pages at high urgency and opens incidents |
| `team_alert_attribute_name` | string | `"Team"` | The built-in alert attribute holding the owning team |
| `ack_timeout_seconds` | number | `300` | Time a level waits before the page moves on |
| `backstop_retries` | number | `2` | Repeats of the backstop path when nobody acks |
| `tier_severity` | list(object) | tier-0 Critical, tier-1 Major | Ordered tier to severity mapping |
| `default_severity` | string | `"Minor"` | Severity for any other tier |
| `grouping_window_seconds` | number | `1800` | Rolling window for one incident per Service |
| `affected_teams_custom_field_name` | string | `null` | Incident custom field that accumulates the team |

## Outputs

| Name | Description |
| --- | --- |
| `alert_source_id` | ID of the HTTP alert source |
| `alert_events_url` | URL monitoring tools post alerts to |
| `alert_source_secret_token` | Bearer token for that URL (sensitive) |
| `alert_route_id` | ID of the route |
| `team_catalog_entry_ids` | Catalog entry ID per team |
| `schedule_ids` | Schedule ID per team |
| `escalation_path_ids` | Escalation path ID per team, including the backstop |

## Design notes

- **No workspace IDs are written down.** The Urgent priority, the Team alert attribute, users, severities and the custom field are looked up by name.
- **Teams and services are data.** Adding a team adds a Catalog entry, a schedule, a rotation and a path through `for_each`; the route is not touched.
- **Urgency belongs to the path, not the route.** The route decides who; the path decides how loudly.
- **Severity is a fact about the service.** It comes from the Catalog's Tier, not from the alert.
- **The Catalog types are named `Team` and `Service`.** A workspace that already has types with those names should import them into this module's addresses.

## Requirements

- Terraform 1.7 or later
- `incident-io/incident` provider 7.6.1 or later, below 8.0.0
- Severity names in `tier_severity` and `default_severity`, and the custom field if set, must already exist in the workspace

## Versioning

Releases are git tags following [Semantic Versioning](https://semver.org). Pin the `ref` in `source` to a tag and review the plan before moving to a new one.

## Development

```bash
make check   # fmt, validate, and validate examples/complete; no API calls
```
