locals {
  # The backstop team is paged when another team does not acknowledge, and
  # owns alerts that nobody else does.
  backstop_team = one([for k, t in var.teams : k if t.backstop])

  # Product teams get their escalation path from the shared template.
  product_teams = { for k, t in var.teams : k => t if !t.backstop }

  # Every person named in var.teams, looked up once.
  emails = toset(flatten([for t in var.teams : concat(t.members, t.on_call)]))
}
