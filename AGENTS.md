# AGENTS.md

A Terraform module for incident.io alert routing. Consumed by [terraform-incidentio-appiahco](https://github.com/karthikgappiah/terraform-incidentio-appiahco).

## Conventions

- **Atomic**: every issue, commit and PR covers one concern. Never bundle unrelated changes.
- **Conventional Commits**: every issue title, commit message and PR title follows the [Conventional Commits](https://www.conventionalcommits.org) spec (`type(scope)!: description`).

## Secrets

- The module takes no credentials. The provider reads `INCIDENT_API_KEY` from the environment of whoever calls it. Never commit `.env` or state.
