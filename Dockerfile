# Dockerfile for Coder with automatic template import
# This extends the official Coder image and adds automatic template import functionality
#
# Build arguments:
#   CODER_VERSION - Version of Coder to use (default: latest)
#   Example: docker build --build-arg CODER_VERSION=v2.27.7 -t coder-unraid:v2.27.7 .

ARG CODER_VERSION=latest
FROM ghcr.io/coder/coder:${CODER_VERSION}

# Set working directory
WORKDIR /home/coder

# Copy template files
COPY docker-workspace.tf /home/coder/templates/docker-workspace.tf
COPY import-template.sh /home/coder/templates/import-template.sh

# Copy entrypoint wrapper
COPY entrypoint-wrapper.sh /usr/local/bin/entrypoint-wrapper.sh

# Make scripts executable
RUN chmod +x /home/coder/templates/import-template.sh && \
    chmod +x /usr/local/bin/entrypoint-wrapper.sh

# Set the wrapper as the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint-wrapper.sh"]

# Default command (can be overridden)
CMD ["--address", "0.0.0.0:7080"]

