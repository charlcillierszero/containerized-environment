# containerized-environment

A comprehensive development environment container based on Ubuntu Noble with modern development tools and languages.

## Included Tools and Languages

- **Base Image**: Ubuntu Noble (24.04 LTS)
- **.NET 10**: Latest .NET SDK with Aspire workload
- **Golang**: Latest stable version
- **Rust**: Latest stable toolchain via rustup
- **Node.js**: Latest LTS version via NVM
- **tmux**: Terminal multiplexer
- **neovim**: Modern text editor
- **Podman**: Container runtime with Podman-in-Podman support

## Building the Image

```bash
# Using Docker
docker build -t dev-environment .

# Using Podman
podman build -t dev-environment .
```

## Running the Container

### Using Docker Compose

The easiest way to run the container is with Docker Compose:

```bash
# Start the container
docker-compose up -d

# Access the container
docker-compose exec dev-environment bash

# Stop the container
docker-compose down
```

### Basic Usage

```bash
# Using Docker
docker run -it dev-environment

# Using Podman
podman run -it dev-environment
```

### Running with Podman-in-Podman Support

For nested container support with Podman, you need to run with additional privileges:

```bash
# Using Podman with privileged mode for nested containers
podman run -it --privileged dev-environment

# Or with specific capabilities
podman run -it \
  --cap-add=SYS_ADMIN \
  --cap-add=MKNOD \
  --device=/dev/fuse \
  --security-opt label=disable \
  dev-environment
```

### Mounting Workspace

```bash
# Mount your local workspace
podman run -it -v $(pwd):/workspace dev-environment
```

## Verifying Installations

Once inside the container, you can verify all installations:

```bash
# .NET
dotnet --version
dotnet workload list

# Golang
go version

# Rust
rustc --version
cargo --version

# Node.js (via NVM)
node --version
npm --version

# Other tools
tmux -V
nvim --version
podman --version
```

## Development Workflow

1. **Start the container** with your workspace mounted
2. **Use tmux** for managing multiple terminal sessions
3. **Use neovim** for editing code
4. **Run podman** commands to build and test containers
5. **Develop** with .NET, Go, Rust, or Node.js

## Notes

- NVM is configured to use the latest LTS version of Node.js by default
- Podman is configured for nested container support with appropriate storage drivers
- All development tools are available in the PATH
- The working directory is set to `/workspace`