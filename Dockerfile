FROM ubuntu:24.04 AS builder

# The former leanprover/lean4:v4.31.0 Docker Hub image is unavailable.
# Elan resolves the project's explicitly pinned lean-toolchain release.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl git build-essential && \
    rm -rf /var/lib/apt/lists/*

ENV ELAN_HOME=/opt/elan
ENV PATH="/opt/elan/bin:${PATH}"

RUN curl -fsSL https://elan.lean-lang.org/elan-init.sh -o /tmp/elan-init.sh && \
    sh /tmp/elan-init.sh -y --default-toolchain none && \
    rm /tmp/elan-init.sh

WORKDIR /opt/lean-optics
COPY . .

RUN elan toolchain install "$(head -n 1 lean-toolchain)" && \
    lake --version && \
    lake update && \
    lake build && \
    lake build lean-optics test-runner bench tests testsAdvanced

FROM ubuntu:24.04

LABEL maintainer="fraware"
LABEL description="Profunctor optics for Lean 4 with law-preserving composition"
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
ENV PATH="/opt/lean-optics/.lake/build/bin:${PATH}"

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD ["lean-optics", "version"]

ENTRYPOINT ["lean-optics"]
