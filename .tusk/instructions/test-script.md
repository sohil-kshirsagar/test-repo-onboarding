# test-script.sh

Runs for each test file. Use `{{file}}` as placeholder for the test file path.
The placeholder is replaced with the relative path from repo root (e.g., `packages/api/src/__tests__/example.test.ts`).

**Goal:** Run only the tests from the specific file to minimize compute time. Most frameworks support this directly, but some (like Go) require extra handling.

## Basic Example

```bash
#!/bin/bash
npx jest {{file}}
```

## Important: PATH Doesn't Persist

Environment variables set in setup-script.sh don't carry over to test-script.sh. Set PATH at the top of each script if needed:

```bash
#!/bin/bash
export PATH="./node_modules/.bin:$PATH"
npx jest {{file}}
```

## Go: Package-Based Testing

Go runs tests at the package level, not individual files. To run only tests from a specific file, extract the test function names:

```bash
#!/bin/bash
set -e
export PATH="/usr/local/go/bin:/go/bin:$PATH"

TEST_FILE="{{file}}"
PACKAGE_DIR=$(dirname "$TEST_FILE")

# Extract test function names from the file
TEST_FUNCTIONS=$(grep -o "^func Test[A-Za-z0-9_]*" "$TEST_FILE" | cut -d' ' -f2 | paste -sd '|' - || true)

if [ -n "$TEST_FUNCTIONS" ]; then
    # Run only the specific test functions
    go test -v -run "^($TEST_FUNCTIONS)$" "./$PACKAGE_DIR"
else
    # Fallback: run all tests in the package
    go test -v "./$PACKAGE_DIR"
fi
```
