data "incident_user" "by_email" {
  for_each = local.emails
  email    = each.value
}
