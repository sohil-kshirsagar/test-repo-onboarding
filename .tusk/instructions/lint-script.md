# lint-script.sh (Optional)

Lints, auto-fixes, and runs build checks (if necessary) for a file. Use `{{file}}` placeholder.

**IMPORTANT:** The lint script must WRITE FIXES when possible, not just report errors. Use `--fix` flags.

**IMPORTANT:** The lint script should also run build checks (if necessary) to ensure that the build works, even though build checks aren't for a specific file.
For example, if it's a typescript project, we should run `tsc --noEmit --incremental` to make sure the build works, try and have build run as fast as possible and avoid side effects.

For example:

```bash
#!/bin/bash
npx eslint --fix {{file}}
npx tsc --noEmit --incremental
```

## Lint Verification Troubleshooting

If verification fails because "lint modified the file", this means the test file had code style issues that were auto-fixed. Since the default branch should pass lint, investigate:

1. **Check if lint is enforced:** Look for pre-commit hooks (.husky/, .pre-commit-config.yaml), CI lint jobs (.github/workflows/, .gitlab-ci.yml)
2. **If lint IS enforced:** Your lint command may be incorrect or using different rules. Match the exact lint config from CI.
3. **If lint is NOT enforced:** The repo may not actually require linting. Consider omitting the lint script entirely and marking lintScriptStatus as "not-needed" when finishing.
