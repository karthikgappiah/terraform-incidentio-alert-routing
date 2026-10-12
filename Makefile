# check runs offline: no API calls, no secrets needed.
.PHONY: check

check:
	terraform fmt -check -recursive
	terraform validate -no-color
	terraform -chdir=examples/complete init -backend=false -input=false >/dev/null
	terraform -chdir=examples/complete validate -no-color
