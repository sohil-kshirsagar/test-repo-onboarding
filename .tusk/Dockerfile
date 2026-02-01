FROM python:3.11-slim

# Install system dependencies (git and curl are required) - runs as root
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set environment
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Switch to non-root user and install Claude Code CLI
# IMPORTANT: Keep this at the END so earlier apt-get commands run as root
USER user
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/user/.local/bin:$PATH"
