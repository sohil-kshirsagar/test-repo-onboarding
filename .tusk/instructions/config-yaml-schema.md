# config.yaml Schema Reference

This document provides the full schema reference for the `.tusk/config.yaml` file.

## Full Schema

```yaml
version: 1

metadata:
  description: "jest unit tests" # Keep concise: 2-4 words like "pytest unit tests", "vitest unit tests", can include subdir if nested, like "example-package unit tests" if app dir is "packages/example-package"
  testFramework: "jest" # jest, pytest, go, rspec, junit, vitest, mocha, etc.

sandbox:
  provider: "e2b"
  dockerfile: "Dockerfile" # OR dockerComposeFile: "docker-compose.yml"
  resources: # Optional, defaults to 8 CPU, 8GB RAM
    numCpus: 8
    memoryMB: 8192

config:
  appDir: "packages/api" # Optional, for monorepos ONLY. Omit or set null for root-level configs. NEVER use "repo" as appDir.
  testFileRegex: "^packages/api/.*[._](test|spec)\\.(ts|tsx)$" # Include appDir if present

scripts:
  setup: "setup-script.sh"
  test: "test-script.sh"
  lint: "lint-script.sh" # Optional
  coverage: "coverage-script.sh" # Optional

envVars: # Optional, non-secret environment variables
  CI: "true"
  NODE_ENV: "test"

testFiles: # For verification - at least 2 test files
  - testFilePath: "packages/api/src/__tests__/example.test.ts"
    sourceFilePath: "packages/api/src/example.ts"
  - testFilePath: "packages/api/src/__tests__/another.test.ts"
    sourceFilePath: "packages/api/src/another.ts"

testCoverageDirs: # Required if coverage script is provided
  - "packages/api/src"
```

## Field Descriptions

### metadata

- `description`: A concise 2-4 word description of the test configuration
- `testFramework`: The testing framework used (jest, pytest, go, rspec, junit, vitest, mocha, etc.)

### sandbox

- `provider`: Always "e2b"
- `dockerfile`: Path to Dockerfile (use this OR dockerComposeFile, not both)
- `dockerComposeFile`: Path to docker-compose.yml (use this OR dockerfile, not both)
- `resources.numCpus`: Number of CPUs (default: 8)
- `resources.memoryMB`: Memory in MB (default: 8192)

### config

- `appDir`: Only for monorepos - the subdirectory containing the app/package. Set to null or omit for single-app repos. **NEVER use "repo" as appDir.**
- `testFileRegex`: Regex pattern to identify test files. Include appDir prefix if present.

### scripts

- `setup`: Script to run before tests (install dependencies)
- `test`: Script to run tests for a specific file (uses `{{file}}` placeholder)
- `lint`: Optional script to lint and auto-fix files (uses `{{file}}` placeholder)
- `coverage`: Optional script to collect test coverage

### envVars

- Non-secret environment variables to set in the sandbox
- Do NOT include secrets here - use `askUserForEnvVars` tool for those

### testFiles

- Array of test files for verification (at least 2)
- `testFilePath`: Path to the test file (relative to repo root)
- `sourceFilePath`: Path to the source file being tested (relative to repo root)

### testCoverageDirs

- **Required if coverage script is provided**
- Array of directories to check for coverage
- Include 2-3 representative source directories to validate coverage works. Provide different nested levels of directories. e.g. if appDir is "packages/api", you should provide "packages/api", "packages/api/src/utils", "packages/api/other-package", etc.
- Paths are relative to repo root, include appDir if present
