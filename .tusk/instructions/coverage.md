## Coverage Script Requirements

**Note:** The guidance below provides suggested approaches for configuring coverage.
These are not the only ways to set up coverage - adapt them to your project's needs.

### CRITICAL: Output File Location
**The coverage report MUST be generated at the expected location for Tusk to parse it.**
- All paths are relative to appDir (if configured) or the repo root
- See framework-specific guidance below for the exact expected file path
- If your coverage tool outputs to a different location, copy/move the file to the expected path

### Script Placeholders
Your coverage script receives these placeholders that are replaced at runtime:
- `{{testFilePaths}}`: Space-separated list of test file paths to run coverage for
- `{{testDirs}}`: Space-separated list of directories to run coverage for

### Script Behavior
The coverage script should handle three scenarios:
1. When `{{testFilePaths}}` is provided: Run coverage for the specified test files
2. When `{{testDirs}}` is provided: Run coverage for all tests in the specified directories
3. When both are empty: Run coverage for the entire repository

Example script structure:
```bash
#!/bin/bash
TEST_FILES="{{testFilePaths}}"
TEST_DIRS="{{testDirs}}"

if [ -n "$TEST_DIRS" ]; then
  # Run coverage for directories
  <coverage-command> $TEST_DIRS
elif [ -n "$TEST_FILES" ]; then
  # Run coverage for specific files
  <coverage-command> $TEST_FILES
else
  # Run coverage for entire repo
  <coverage-command>
fi
```

### Setup Requirements
If your project needs additional packages for coverage (e.g., coverage reporters, plugins):
- Install them in your setup-script.sh, not in the coverage script
- Example: `npm install --save-dev @vitest/coverage-v8`

## Framework-Specific Setup

### Expected Output
File: `coverage.json` (relative to appDir if set)

### Installation
Add to setup-script.sh:
```bash
pip install pytest-cov
```

### Coverage Script Example
```bash
pytest --cov=src --cov-report=json:coverage.json {{testFilePaths}}
```

### Configuration Notes
- The `--cov=src` path should match your source directory
- Use `--cov-report=json:coverage.json` to output JSON format
- The coverage.json file contains both summary and line-level coverage data