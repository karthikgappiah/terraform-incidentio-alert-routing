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
