FROM leanprover/lean4:4.8.0 AS builder

WORKDIR /opt/lean-optics
COPY . .
RUN lake build

FROM ubuntu:24.04

LABEL maintainer="fraware"
LABEL description="Industrial-quality optics over profunctors with law-carrying composition"
LABEL org.opencontainers.image.source="https://github.com/fraware/lean-optics"
LABEL org.opencontainers.image.documentation="https://github.com/fraware/lean-optics/blob/main/README.md"

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    rm -rf /var/lib/apt/lists/* && \
    useradd --create-home --uid 10001 --shell /bin/bash leanuser

WORKDIR /opt/lean-optics
COPY --from=builder /opt/lean-optics /opt/lean-optics
RUN chown -R leanuser:leanuser /opt/lean-optics

USER leanuser
ENV LEAN_PATH="/opt/lean-optics/build/lib"
ENV PATH="/opt/lean-optics/build/bin:$PATH"

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD ["/opt/lean-optics/build/bin/lean-optics", "--version"]

ENTRYPOINT ["/opt/lean-optics/build/bin/lean-optics"]
