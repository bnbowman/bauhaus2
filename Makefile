ENABLED_CRAM_TESTS_SHORT = \
	test/cram/describeWorkflows \
	test/cram/generate \
	test/cram/homeless \
	test/cram/listWorkflows \
	test/cram/validationErrors

ENABLED_CRAM_TESTS_INTERNAL = \
	test/cram/internal/executionTest \
	test/cram/internal/ccsTest \
	test/cram/internal/cas9YieldTest \
	test/cram/internal/unrolledExecutionTest \
	test/cram/internal/unrolledMultipleContigsExecutionTest \
	test/cram/internal/arrowTrainExecutionTest \
	test/cram/internal/heatmaps \
	test/cram/internal/barcodingQCTest \
	test/cram/internal/coveragetitrationExecutionTest \
	test/cram/internal/isoseqExecutionTest \
	test/cram/internal/constantarrowTest \
	test/cram/internal/primaryExecutionTest

.SUFFIXES: .t

.t:
	time cram $<

test: $(ENABLED_CRAM_TESTS_SHORT)

check: test

## Tests that require PacBio NFS
internal-tests: $(ENABLED_CRAM_TESTS_INTERNAL)

all-tests: test internal-tests

.PHONY: check test internal-tests all-tests
