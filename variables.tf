variable "teams" {
  description = <<-EOT
    Every team that can be paged, keyed by the team's ID in the Catalog (its
    external ID). Alerts and services refer to teams by this key.

    members:  people shown on the team in the Catalog (emails).
    on_call:  people in the team's weekly rotation (emails).
    aliases:  other names an alert may use for the team, such as a legacy label.
    backstop: exactly one team is the backstop. It is paged when a team does not
              acknowledge, and it owns alerts nobody else does.
  EOT

  type = map(object({
    name     = string
    aliases  = optional(list(string), [])
    members  = list(string)
    on_call  = list(string)
    backstop = optional(bool, false)
  }))

  validation {
    condition     = length([for t in var.teams : t if t.backstop]) == 1
    error_message = "Exactly one team must set backstop = true."
  }
}

variable "services" {
  description = <<-EOT
    Every service that can send alerts, keyed by the value monitoring tools put
    in metadata.service. owner is a key of var.teams.

    tier:      how critical the service is. It drives incident severity through
               var.tier_severity. Omit for a service that should not open
               higher than the default severity.
    lifecycle: free text, such as production or deprecated.
  EOT

  type = map(object({
    owner     = string
    tier      = optional(string)
    lifecycle = string
    aliases   = optional(list(string), [])
  }))
}

variable "team_type_description" {
  description = "Description of the Team Catalog type."
  type        = string
  default     = "All teams that can be paged."
}

variable "service_type_description" {
  description = "Description of the Service Catalog type."
  type        = string
  default     = "Services that send alerts, and the team that owns each."
}

variable "rotation_start" {
  description = "When every team's first weekly shift starts, as an RFC 3339 timestamp. Pick a Monday at the hour you want handover to happen, in the past if someone should be on call now."
  type        = string

  validation {
    condition     = can(formatdate("YYYY", var.rotation_start))
    error_message = "rotation_start must be an RFC 3339 timestamp, such as 2026-10-05T16:00:00Z."
  }
}

variable "timezone" {
  description = "IANA timezone of every schedule and of working hours."
  type        = string
  default     = "UTC"
}

variable "holiday_country_codes" {
  description = "Countries whose public holidays are shown on every schedule. Empty shows none."
  type        = list(string)
  default     = []
}

variable "urgent_priority_name" {
  description = "Name of the alert priority that pages at high urgency and opens incidents. Priorities are built into incident.io; this one must exist."
  type        = string
  default     = "Urgent"
}

variable "ack_timeout_seconds" {
  description = "How long a level waits for an acknowledgement before the page moves on."
  type        = number
  default     = 300
}

variable "backstop_retries" {
  description = "How many times the backstop team's path repeats when nobody acknowledges."
  type        = number
  default     = 2
}

variable "alert_source_name" {
  description = "Name of the HTTP alert source that monitoring tools post to."
  type        = string
  default     = "Alert routing"
}

variable "team_alert_attribute_name" {
  description = "Name of the built-in alert attribute that holds the alert's owning team."
  type        = string
  default     = "Team"
}
