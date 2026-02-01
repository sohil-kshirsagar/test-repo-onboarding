# Docker Compose Setup Guide

This guide covers how to create docker-compose configurations for E2B sandboxes.

## When to Use Docker Compose

**Use Docker Compose (`sandbox.dockerComposeFile: "docker-compose.yml"`)** when:

- Tests require real database connections (MySQL, PostgreSQL, MongoDB)
- Tests need Redis, RabbitMQ, or other services
- Integration-style unit tests that need multiple containers

## Required Structure

**CRITICAL**: Your docker-compose file MUST have:

1. A service named `app` where tests run
2. `working_dir: /repo` on the app service
3. `command: "tail -f /dev/null"` to keep the container running
4. Volume mount `./home/user/repo:/repo`

```yaml
name: my-project-tests

services:
  app:
    image: node:22-slim
    working_dir: /repo # REQUIRED
    command: "tail -f /dev/null" # REQUIRED - keeps container running
    volumes:
      - ./home/user/repo:/repo # REQUIRED - this is where the repo is mounted
    environment:
      - CI=true
      - NODE_ENV=test
      # How to pass through envVars from config.yaml or envVars provided as secrets
      - DATABASE_URL
      # Might need to do this since some CIs implicitly have PATH but this docker service does not
      - PATH=/root/.local/bin:${PATH}
    depends_on:
      db:
        condition: service_healthy

  db:
    image: postgres:16
    environment:
      POSTGRES_DB: test
      POSTGRES_USER: test
      POSTGRES_PASSWORD: test
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U test"]
      interval: 5s
      timeout: 5s
      retries: 5
```

## Environment Variable Passthrough

Variables defined in `envVars` of config.yaml are available in the container. To pass them to services:

```yaml
services:
  app:
    environment:
      # Static values
      - CI=true
      # Passthrough from envVars (no value = use env var)
      - DATABASE_URL
      - API_KEY
```

## Service Health Checks

Always add health checks for dependencies to ensure they're ready before tests run:

```yaml
services:
  mysql:
    image: mysql:8
    environment:
      MYSQL_DATABASE: test
      MYSQL_ALLOW_EMPTY_PASSWORD: "yes"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "--silent"]
      interval: 5s
      timeout: 5s
      retries: 10

  redis:
    image: redis:7
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 5s
      retries: 5

  mongodb:
    image: mongo:7
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 5s
      timeout: 5s
      retries: 5
```

## E2B Pre-built Templates

Docker Compose setups use pre-built E2B templates with fixed resources:

- **medium**: 8 CPU, 8 GB RAM (default)
- **large**: 16 CPU, 16 GB RAM

Set the resources in config.yaml:

```yaml
sandbox:
  provider: e2b
  dockerComposeFile: docker-compose.yml
  resources:
    numCpus: 8 # 8 for medium, 16 for large
    memoryMB: 8192 # 8192 for medium, 16384 for large
```

## Common Pitfalls

1. **Missing tail command**: Docker-compose app service needs `command: "tail -f /dev/null"`
2. **No health checks**: Services may not be ready when tests start
3. **Hardcoded env vars**: Use passthrough for secrets from config.yaml envVars
4. **Wrong working_dir for docker-compose**: Use `working_dir: /repo` for the app service in docker-compose
