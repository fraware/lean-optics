# Lean Optics - Production Docker Image
# =====================================

# Use the official Lean 4 image as base
FROM leanprover/lean4:4.8.0

# Set metadata
LABEL maintainer="fraware"
LABEL description="Industrial-quality optics over profunctors with law-carrying composition"
LABEL version="1.0.0"
LABEL org.opencontainers.image.source="https://github.com/fraware/lean-optics"
LABEL org.opencontainers.image.documentation="https://github.com/fraware/lean-optics/blob/main/README.md"

# Set working directory
WORKDIR /opt/lean-optics

# Copy project files
COPY . .

# Build the project
RUN lake build

# Create a non-root user for security
RUN adduser --disabled-password --gecos '' leanuser && \
    chown -R leanuser:leanuser /opt/lean-optics

# Switch to non-root user
USER leanuser

# Set environment variables
ENV LEAN_PATH="/opt/lean-optics/build/lib"
ENV PATH="/opt/lean-optics/build/bin:$PATH"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD lake exe lean-optics --version || exit 1

# Default command
CMD ["lake", "exe", "lean-optics"]

# Expose any ports if needed in the future
# EXPOSE 8080

# Create entrypoint script for flexible execution
COPY --chown=leanuser:leanuser <<EOF /opt/lean-optics/entrypoint.sh
#!/bin/bash
set -e

# Handle different commands
case "\${1:-help}" in
    "help"|"--help"|"-h")
        lake exe lean-optics
        ;;
    "test")
        echo "Running test suite..."
        lake exe test-runner
        ;;
    "bench"|"benchmark")
        echo "Running benchmarks..."
        lake exe bench
        ;;
    "build")
        echo "Building project..."
        lake build
        ;;
    "clean")
        echo "Cleaning build artifacts..."
        lake clean
        ;;
    "version"|"--version"|"-v")
        lake exe lean-optics --version 2>/dev/null || echo "Lean Optics v1.0.0"
        ;;
    *)
        echo "Unknown command: \$1"
        echo "Available commands: help, test, bench, build, clean, version"
        exit 1
        ;;
esac
EOF

RUN chmod +x /opt/lean-optics/entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/opt/lean-optics/entrypoint.sh"]
