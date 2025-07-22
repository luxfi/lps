<div align="center">
  <img src="resources/LuxLogoRed.png?raw=true">
</div>

---

Node implementation for the [Lux](https://lux.network) network -
a blockchains platform with high throughput, and blazing fast transactions.

## Installation

Lux is an incredibly lightweight protocol, so the minimum computer requirements are quite modest.
Note that as network usage increases, hardware requirements may change.

The minimum recommended hardware specification for nodes connected to Mainnet is:

- CPU: Equivalent of 8 AWS vCPU
- RAM: 16 GiB
- Storage: 1 TiB
  - Nodes running for very long periods of time or nodes with custom configurations may observe higher storage requirements.
- OS: Ubuntu 22.04/24.04 or macOS >= 12
- Network: Reliable IPv4 or IPv6 network connection, with an open public port.

If you plan to build Lux from source, you will also need the following software:

- [Go](https://golang.org/doc/install) version >= 1.23.9
- [gcc](https://gcc.gnu.org/)
- g++

### Building From Source

#### Clone The Repository

Clone the Lux repository:

```sh
git clone git@github.com:luxfi/node.git
cd luxd
```

This will clone and checkout the `master` branch.

#### Building Lux

Build Lux by running the build task:

```sh
./scripts/run_task.sh build
```

The `luxd` binary is now in the `build` directory. To run:

```sh
./build/luxd
```

### Binary Repository

Install Lux using an `apt` repository.

#### Adding the APT Repository

If you already have the APT repository added, you do not need to add it again.

To add the repository on Ubuntu, run:

```sh
sudo su -
wget -qO - https://downloads.lux.network/luxd.gpg.key | tee /etc/apt/trusted.gpg.d/luxd.asc
source /etc/os-release && echo "deb https://downloads.lux.network/apt $UBUNTU_CODENAME main" > /etc/apt/sources.list.d/lux.list
exit
```

#### Installing the Latest Version

After adding the APT repository, install `luxd` by running:

```sh
sudo apt update
sudo apt install luxd
```

### Binary Install

Download the [latest build](https://github.com/luxfi/node/releases/latest) for your operating system and architecture.

The Lux binary to be executed is named `luxd`.

### Docker Install

Make sure Docker is installed on the machine - so commands like `docker run` etc. are available.

Building the Docker image of latest `luxd` branch can be done by running:

```sh
./scripts/run-task.sh build-image
```

To check the built image, run:

```sh
docker image ls
```

The image should be tagged as `avaplatform/luxd:xxxxxxxx`, where `xxxxxxxx` is the shortened commit of the Lux source it was built from. To run the Lux node, run:

```sh
docker run -ti -p 9650:9650 -p 9651:9651 avaplatform/luxd:xxxxxxxx /luxd/build/luxd
```

## Running Lux

### Connecting to Mainnet

To connect to the Lux Mainnet, run:

```sh
./build/luxd
```

You should see some pretty ASCII art and log messages.

You can use `Ctrl+C` to kill the node.

### Connecting to Fuji

To connect to the Fuji Testnet, run:

```sh
./build/luxd --network-id=fuji
```

### Creating a Local Testnet

The [lux-cli](https://github.com/luxfi/lux-cli) is the easiest way to start a local network.

```sh
lux network start
lux network status
```

### Single-Node Development Mode

For quick local development, you can run a single-node Lux network with sybil protection disabled:

```sh
# Using the convenience script
./scripts/run_dev.sh

# Or manually with all options
./build/luxd \
    --network-id=local \
    --sybil-protection-enabled=false \
    --http-host=0.0.0.0 \
    --http-port=9630 \
    --staking-port=9631 \
    --api-admin-enabled=true \
    --api-keystore-enabled=true \
    --api-metrics-enabled=true
```

The single-node dev mode provides:
- **HTTP RPC endpoint**: `http://localhost:9630`
- **WebSocket endpoint**: `ws://localhost:9630/ext/bc/C/ws`
- **C-Chain RPC**: `http://localhost:9630/ext/bc/C/rpc`

You can interact with the C-Chain using standard Ethereum tools:
```sh
# Example using curl
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' \
     -H "Content-Type: application/json" \
     http://localhost:9630/ext/bc/C/rpc
```

**Note**: Single-node mode with sybil protection disabled should only be used for development. Never use this configuration on public networks (Mainnet or Fuji).

## Bootstrapping

A node needs to catch up to the latest network state before it can participate in consensus and serve API calls. This process (called bootstrapping) currently takes several days for a new node connected to Mainnet.

A node will not [report healthy](https://build.lux.network/docs/api-reference/health-api) until it is done bootstrapping.

Improvements that reduce the amount of time it takes to bootstrap are under development.

The bottleneck during bootstrapping is typically database IO. Using a more powerful CPU or increasing the database IOPS on the computer running a node will decrease the amount of time bootstrapping takes.

## Generating Code

Lux uses multiple tools to generate efficient and boilerplate code.

### Running protobuf codegen

To regenerate the protobuf go code, run `scripts/run-task.sh generate-protobuf` from the root of the repo.

This should only be necessary when upgrading protobuf versions or modifying .proto definition files.

To use this script, you must have [buf](https://docs.buf.build/installation) (v1.31.0), protoc-gen-go (v1.33.0) and protoc-gen-go-grpc (v1.3.0) installed.

To install the buf dependencies:

```sh
go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.33.0
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.3.0
```

If you have not already, you may need to add `$GOPATH/bin` to your `$PATH`:

```sh
export PATH="$PATH:$(go env GOPATH)/bin"
```

If you extract buf to ~/software/buf/bin, the following should work:

```sh
export PATH=$PATH:~/software/buf/bin/:~/go/bin
go get google.golang.org/protobuf/cmd/protoc-gen-go
go get google.golang.org/protobuf/cmd/protoc-gen-go-grpc
scripts/run_task.sh generate-protobuf
```

For more information, refer to the [GRPC Golang Quick Start Guide](https://grpc.io/docs/languages/go/quickstart/).

### Running mock codegen

See [the Contributing document autogenerated mocks section](CONTRIBUTING.md####Autogenerated-mocks).

## Versioning

### Version Semantics

Lux is first and foremost a client for the Lux network. The versioning of Lux follows that of the Lux network.

- `v0.x.x` indicates a development network version.
- `v1.x.x` indicates a production network version.
- `vx.[Upgrade].x` indicates the number of network upgrades that have occurred.
- `vx.x.[Patch]` indicates the number of client upgrades that have occurred since the last network upgrade.

### Library Compatibility Guarantees

Because Lux's version denotes the network version, it is expected that interfaces exported by Lux's packages may change in `Patch` version updates.

### API Compatibility Guarantees

APIs exposed when running Lux will maintain backwards compatibility, unless the functionality is explicitly deprecated and announced when removed.

## Supported Platforms

Lux can run on different platforms, with different support tiers:

- **Tier 1**: Fully supported by the maintainers, guaranteed to pass all tests including e2e and stress tests.
- **Tier 2**: Passes all unit and integration tests but not necessarily e2e tests.
- **Tier 3**: Builds but lightly tested (or not), considered _experimental_.
- **Not supported**: May not build and not tested, considered _unsafe_. To be supported in the future.

The following table lists currently supported platforms and their corresponding
Lux support tiers:

| Architecture | Operating system | Support tier  |
| :----------: | :--------------: | :-----------: |
|    amd64     |      Linux       |       1       |
|    arm64     |      Linux       |       2       |
|    amd64     |      Darwin      |       2       |
|    amd64     |     Windows      | Not supported |
|     arm      |      Linux       | Not supported |
|     i386     |      Linux       | Not supported |
|    arm64     |      Darwin      | Not supported |

To officially support a new platform, one must satisfy the following requirements:

| Lux continuous integration | Tier 1  | Tier 2  | Tier 3  |
| ---------------------------------- | :-----: | :-----: | :-----: |
| Build passes                       | &check; | &check; | &check; |
| Unit and integration tests pass    | &check; | &check; |         |
| End-to-end and stress tests pass   | &check; |         |         |

## Security Bugs

**We and our community welcome responsible disclosures.**

Please refer to our [Security Policy](SECURITY.md) and [Security Advisories](https://github.com/luxfi/node/security/advisories).
