#!/bin/bash
set -e

# Set PYTHONPATH to repo root
export PYTHONPATH=/home/user/repo

# Run black to auto-fix formatting issues
black {{file}}

# Run pylint for code quality checks but don't fail on warnings
pylint {{file}} --exit-zero || true
