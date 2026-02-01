# testFileRegex Patterns

The regex identifies test files. **Always include appDir in the pattern if present.**

Examples:

- Jest (root): `".*[._](test|spec)\\.(js|jsx|ts|tsx)$"`
- Jest (appDir=client): `"^client/.*[._](test|spec)\\.(ts|tsx)$"`
- Jest (**tests** folder): `"^app/(?:.*[._](?:test|spec).(ts|tsx)|.*__tests__/.*.(ts|tsx))$"`
- Jest (multiple dirs): `"^(app|client|sharedModules)/.*[._-](test|spec).(js|jsx|ts|tsx)$"`
- Pytest: `"^src/.*/(test_.*|.*_test)\\.py$"`
- Go: `"^.*_test\\.go$"`
- RSpec: `"^spec/.*_spec\\.rb$"`
- JUnit: `"^src/test/.*Test\\.java$"`
