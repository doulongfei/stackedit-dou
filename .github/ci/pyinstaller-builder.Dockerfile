FROM python:3.11-slim

ARG TARGETPLATFORM
ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    zip \
    unzip \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /work

# Install pyinstaller and put a simple entrypoint script
RUN python -m pip install --upgrade pip setuptools wheel && \
    python -m pip install pyinstaller==6.17.0

# Image entrypoint will not run build by default; CI will mount repo and run script
CMD ["/bin/bash"]
