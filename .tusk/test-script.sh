#!/bin/bash
set -e

# Set PYTHONPATH to repo root
export PYTHONPATH=/home/user/repo

# Run the specific test file
pytest {{file}} -v
