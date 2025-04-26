FROM amazonlinux:2023

# Install basic tools
RUN dnf update -y && \
    dnf install -y \
    unzip \
    git \
    gnupg \
    shadow-utils \
    sudo \
    less \
    which \
    tar \
    gzip \
    && dnf clean all

# Install full curl properly, replacing curl-minimal
RUN dnf install -y --allowerasing curl

# Install jq manually
RUN curl -Lo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && \
    chmod +x /usr/local/bin/jq

# Create workspace directory
RUN mkdir -p /workspaces

# Create vscode user
RUN useradd -m vscode && echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vscode

# Set working directory
WORKDIR /workspaces

# Switch to vscode user
USER vscode

CMD ["bash"]