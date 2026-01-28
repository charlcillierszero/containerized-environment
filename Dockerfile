FROM ubuntu:noble

# Use bash with pipefail for safety
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=lts/*
ENV PATH="/root/.nvm/versions/node/default/bin:${PATH}"
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH="${DOTNET_ROOT}:${PATH}"
ENV GOROOT=/usr/local/go
ENV GOPATH=/root/go
ENV PATH="${GOROOT}/bin:${GOPATH}/bin:${PATH}"
ENV CARGO_HOME=/root/.cargo
ENV RUSTUP_HOME=/root/.rustup
ENV PATH="${CARGO_HOME}/bin:${PATH}"

# Update and upgrade system
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    ca-certificates \
    curl \
    wget \
    git \
    build-essential \
    software-properties-common \
    apt-transport-https \
    gnupg \
    lsb-release \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install tmux
RUN apt-get update && \
    apt-get install -y tmux && \
    rm -rf /var/lib/apt/lists/*

# Install neovim
RUN apt-get update && \
    apt-get install -y neovim && \
    rm -rf /var/lib/apt/lists/*

# Install .NET 10
RUN wget --progress=dot:giga https://dot.net/v1/dotnet-install.sh -O /tmp/dotnet-install.sh && \
    chmod +x /tmp/dotnet-install.sh && \
    /tmp/dotnet-install.sh --channel 10.0 --install-dir /usr/share/dotnet && \
    ln -s /usr/share/dotnet/dotnet /usr/local/bin/dotnet && \
    rm /tmp/dotnet-install.sh

# Install Aspire workload for .NET
RUN dotnet workload update && \
    dotnet workload install aspire

# Install Golang
RUN GOLANG_VERSION=$(curl -s https://go.dev/VERSION?m=text | head -n1) && \
    wget --progress=dot:giga "https://go.dev/dl/${GOLANG_VERSION}.linux-amd64.tar.gz" -O /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . ${CARGO_HOME}/env && \
    rustup default stable

# Install NVM and Node.js LTS
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && \
    . ${NVM_DIR}/nvm.sh && \
    nvm install --lts && \
    nvm alias default 'lts/*' && \
    nvm use default && \
    ln -sf ${NVM_DIR}/versions/node/$(nvm version default)/bin/node /usr/local/bin/node && \
    ln -sf ${NVM_DIR}/versions/node/$(nvm version default)/bin/npm /usr/local/bin/npm && \
    ln -sf ${NVM_DIR}/versions/node/$(nvm version default)/bin/npx /usr/local/bin/npx

# Install Podman for Podman-in-Podman support
RUN apt-get update && \
    apt-get install -y podman fuse-overlayfs slirp4netns && \
    rm -rf /var/lib/apt/lists/*

# Configure Podman storage for rootless/nested usage
RUN mkdir -p /etc/containers && \
    echo '[storage]' > /etc/containers/storage.conf && \
    echo 'driver = "overlay"' >> /etc/containers/storage.conf && \
    echo '[storage.options]' >> /etc/containers/storage.conf && \
    echo 'mount_program = "/usr/bin/fuse-overlayfs"' >> /etc/containers/storage.conf

# Set up podman for nested containers
RUN mkdir -p /root/.config/containers && \
    echo '[containers]' > /root/.config/containers/containers.conf && \
    echo 'netns="host"' >> /root/.config/containers/containers.conf && \
    echo 'userns="host"' >> /root/.config/containers/containers.conf && \
    echo 'ipcns="host"' >> /root/.config/containers/containers.conf && \
    echo 'utsns="host"' >> /root/.config/containers/containers.conf && \
    echo 'cgroupns="host"' >> /root/.config/containers/containers.conf && \
    echo 'cgroups="disabled"' >> /root/.config/containers/containers.conf && \
    echo '[engine]' >> /root/.config/containers/containers.conf && \
    echo 'cgroup_manager="cgroupfs"' >> /root/.config/containers/containers.conf && \
    echo 'events_logger="file"' >> /root/.config/containers/containers.conf

# Verify installations
RUN dotnet --version && \
    dotnet workload list && \
    go version && \
    rustc --version && \
    cargo --version && \
    . ${NVM_DIR}/nvm.sh && node --version && \
    . ${NVM_DIR}/nvm.sh && npm --version && \
    tmux -V && \
    nvim --version && \
    podman --version

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]
