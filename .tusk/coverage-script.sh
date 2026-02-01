#!/bin/bash
set -e

# Set PYTHONPATH to repo root
export PYTHONPATH=/home/user/repo

TEST_FILES="{{testFilePaths}}"
TEST_DIRS="{{testDirs}}"

if [ -n "$TEST_DIRS" ]; then
  # Run coverage for directories
  pytest --cov=. --cov-report=json:coverage.json $TEST_DIRS
elif [ -n "$TEST_FILES" ]; then
  # Run coverage for specific files
  pytest --cov=. --cov-report=json:coverage.json $TEST_FILES
else
  # Run coverage for entire repo
  pytest --cov=. --cov-report=json:coverage.json
fi
