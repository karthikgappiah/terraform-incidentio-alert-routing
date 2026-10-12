# check runs offline: no API calls, no secrets needed.
.PHONY: check

check:
	terraform fmt -check -recursive
	terraform validate -no-color
