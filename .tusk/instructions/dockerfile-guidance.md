# Dockerfile Setup Guide

This guide covers how to create Dockerfiles for E2B sandboxes.

## When to Use Dockerfile

**Use Dockerfile (`sandbox.dockerfile: "Dockerfile"`)** when:

- Unit tests only need the application runtime (Node.js, Python, etc.)
- Tests mock external services (databases, APIs, caches)
- No network services are required

## Base Image Selection

Choose slim/minimal images to reduce build time:

```dockerfile
# Node.js
FROM node:22-slim
FROM node:20-slim

# Python
FROM python:3.12-slim
FROM python:3.11-slim

# Go
FROM golang:1.22-alpine
FROM golang:1.21-alpine

# Ruby
FROM ruby:3.3-slim
FROM ruby:3.2-slim

# Java
FROM eclipse-temurin:21-jdk
FROM eclipse-temurin:17-jdk

# .NET
FROM mcr.microsoft.com/dotnet/sdk:8.0
```

## Required Packages

**CRITICAL**: The following utilities MUST be installed in the container:

1. **git** - Required for cloning the repository
2. **curl** - Required for installing Claude Code CLI
3. **Claude Code CLI** - Required for agentic test generation

```dockerfile
FROM node:22-slim

# Install git and other system dependencies (as root)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Switch to non-root user for Claude Code installation
# IMPORTANT: Add this at the END of your Dockerfile so earlier commands run as root
USER user
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/user/.local/bin:$PATH"
```

Verification will fail with a `base-utilities` error if these are missing.

## Package Installation Best Practices

1. **Combine RUN commands** to reduce layers:

```dockerfile
# GOOD - Single layer, cleanup included
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# BAD - Multiple layers, no cleanup
RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y curl
```

2. **DON'T install application dependencies in Dockerfile**:

```dockerfile
# BAD - Don't do this
COPY package.json .
RUN npm install

# GOOD - Application dependencies go in setup-script.sh
# Dockerfile should only have system-level dependencies
```

The repo is NOT available during Docker build. Dependencies like `npm install`, `pip install`, etc. go in the setup script.

## Cache Layer Optimization

Order commands from least-frequently-changed to most-frequently-changed:

```dockerfile
FROM node:22-slim

# System dependencies (rarely change)
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# Environment setup (occasionally changes)
ENV NODE_ENV=test
ENV CI=true

# NOTE: Do NOT set WORKDIR - Tusk handles this internally
```

## E2B-Specific Considerations

1. **Working Directory**: The repo is cloned to `/home/user/repo`. **Do NOT set WORKDIR** in your Dockerfile - Tusk manages the working directory internally. Setting WORKDIR can cause the repo to be cloned to the wrong location.
2. **User Permissions**: The Claude Code CLI must be installed as `user`, but system packages (apt-get) should run as root first.
3. **No ENTRYPOINT/CMD**: E2B manages the container lifecycle.

## Example Complete Dockerfile

```dockerfile
FROM node:22-slim

# Install system dependencies (git and curl are required) - runs as root
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set environment
ENV NODE_ENV=test
ENV CI=true

# NOTE: Do NOT set WORKDIR - Tusk handles working directory internally.
# The repo will be cloned to /home/user/repo automatically.

# Switch to non-root user and install Claude Code CLI
# IMPORTANT: Keep this at the END so earlier apt-get commands run as root
USER user
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/user/.local/bin:$PATH"
```

## Common Pitfalls

1. **Missing git or curl or Claude Code**: Always install both `git` and `curl` and Claude Code CLI in Dockerfile
2. **Installing deps in Dockerfile**: npm install/pip install go in setup script
3. **Setting WORKDIR in Dockerfile**: Do NOT set WORKDIR - Tusk handles working directory internally. Setting WORKDIR causes the repo to be cloned to the wrong location.
