FROM ubuntu:noble

# Use bash with pipefail for safety
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV NVM_DIR=/root/.nvm
ENV NODE_VERSION=lts/*
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH="${DOTNET_ROOT}:${PATH}"
ENV GOROOT=/usr/local/go
ENV GOPATH=/root/go
ENV PATH="${GOROOT}/bin:${GOPATH}/bin:${PATH}"
ENV CARGO_HOME=/root/.cargo
ENV RUSTUP_HOME=/root/.rustup
ENV PATH="${CARGO_HOME}/bin:${PATH}"

# Add aliases
RUN echo "alias cls='clear'" >> ~/.bash_aliases \
    && echo "alias c='clear'" >> ~/.bash_aliases \
    && echo "alias fix-apt-get='echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null'" >> ~/.bash_aliases \
    && echo "alias vim='nvim'" >> ~/.bash_aliases \
    && echo "alias reload-bashrc='. ~/.bashrc'" >> ~/.bash_aliases \
    && echo "alias go-home='cd ~'" >> ~/.bash_aliases

# Update and upgrade system
RUN apt-get update \
    && apt-get upgrade -y

# Install essential packages
RUN apt-get install -y build-essential
RUN apt-get install -y ca-certificates 
RUN apt-get install -y software-properties-common
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y git 
RUN apt-get install -y unzip
RUN apt-get install -y apt-transport-https
RUN apt-get install -y gnupg
RUN apt-get install -y lsb-release
RUN apt-get install -y ripgrep
RUN apt-get install -y luarocks
RUN apt-get install -y net-tools
RUN apt-get install -y fontconfig

# Install nvm and node
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash \
    && export NVM_DIR="$HOME/.nvm" \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" \
    && node -v

# Install .NET SDK
RUN add-apt-repository ppa:dotnet/backports \
    && apt-get update -y \
    && apt-get install -y dotnet-sdk-10.0

# Install Podman
RUN apt-get update -y \
    && apt-get install -y podman

# Install tmux
RUN apt-get install -y tmux \
    && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
COPY ./.tmux.conf ~/.tmux.conf

# Install GoLang
RUN wget https://go.dev/dl/go1.25.6.linux-amd64.tar.gz \
    && tar -xvf go1.25.6.linux-amd64.tar.gz \
    && mv go go-1.25.6 \
    && mv go-1.25.6 /usr/local \
    && rm -rf go1.25.6.linux-amd64.tar.gz \
    && echo "export GOROOT=/usr/local/go-1.25.6" >> ~/.bashrc \
    && echo "export GOPATH=\$HOME/go" >> ~/.bashrc \
    && echo "export PATH=\$GOPATH/bin:\$GOROOT/bin:\$PATH" >> ~/.bashrc

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Install Nerd Fonts
RUN mkdir -p ~/.local/share/fonts \
    && wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip \
    && unzip JetBrainsMono.zip -d ~/.local/share/fonts \
    && rm JetBrainsMono.zip \
    && fc-cache -fv

# Install nvim
RUN apt-get update -y \
    && curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
    && tar -C /opt -xzf nvim-linux-x86_64.tar.gz \
    && rm -rf ./nvim-linux-x86_64.tar.gz \
    && echo "export PATH=\$PATH:/opt/nvim-linux-x86_64/bin" >> ~/.bashrc \
    && git clone https://github.com/LazyVim/starter ~/.config/nvim \
    && rm -rf ~/.config/nvim/.git

WORKDIR /root

# Default command
CMD ["/bin/bash"]
