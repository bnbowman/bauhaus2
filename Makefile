
check:
test:
	cram test/cram/*.t

## Tests that require PacBio NFS
internal-tests:
	cram test/cram/internal/*.t

all-tests: test internal-tests

.PHONY: check test internal-tests all-tests
