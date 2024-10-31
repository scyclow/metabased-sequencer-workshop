FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Switch to root to install system dependencies
USER root
RUN apt-get update && \
    apt-get install -y curl build-essential git && \
    rm -rf /var/lib/apt/lists/*

# Switch to vscode user to install foundry
USER vscode
RUN curl -L https://foundry.paradigm.xyz | bash
ENV PATH="/home/vscode/.foundry/bin:${PATH}"
RUN /home/vscode/.foundry/bin/foundryup

# Create source directory and set workspace
WORKDIR /workspace