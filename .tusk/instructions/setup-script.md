# setup-script.sh

Runs once before testing. Install dependencies here.

```bash
#!/bin/bash
npm install
```

## Important: Environment Variables Don't Persist

Environment variables and PATH modifications set in setup-script.sh do NOT carry over to test-script.sh, lint-script.sh, or coverage-script.sh. Each script runs in a fresh shell.

If you need specific PATH entries (e.g., for node_modules/.bin, Python venv, or Go binaries), set them at the top of EACH script that needs them:

```bash
# Node
export PATH="./node_modules/.bin:$PATH"

# Python venv
export PATH="/home/user/repo/.venv/bin:$PATH"

# Go
export PATH="/usr/local/go/bin:/go/bin:$PATH"
```
