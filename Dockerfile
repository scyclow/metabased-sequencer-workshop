# Use Ubuntu as base image
FROM ubuntu:22.04

# Prevent tzdata questions during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    curl \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install Foundry
RUN curl -L https://foundry.paradigm.xyz | bash && \
    ~/.foundry/bin/foundryup

# Add Foundry binaries to PATH
ENV PATH="/root/.foundry/bin:${PATH}"

# Set the working directory
WORKDIR /app

# Copy just the dependency files first
COPY foundry.toml ./
COPY .gitmodules ./
COPY remappings.txt ./

# Install dependencies
RUN forge install

# Copy the rest of the repository
COPY . .

# Build the project
RUN forge build

# Command to run when container starts
CMD ["bash"]