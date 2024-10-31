# Metabased Sequencer Chain Modules Workshop

## Overview

The Metabased Sequencer Chain is a modular protocol for sequencing transactions in Layer 3 chains. It uses a flexible system of modules to determine who is allowed to sequence transactions.

## Key Components

1. **MetabasedSequencerChain**: The core contract for sequencing transactions.
2. **RequireListManager**: Manages the list of modules that determine sequencing permissions.
3. **Modules**: Implement the `IsAllowed` interface to define custom sequencing criteria.

## Getting Started

### With Dev Container (Recommended)

The easiest way to get started is using VS Code's Dev Containers. This approach provides a consistent development environment with all required dependencies pre-installed.

#### Prerequisites

1. Install [VS Code](https://code.visualstudio.com/)
2. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
3. Install the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) in VS Code

#### Setup Instructions

1. Clone the repository:

   ```bash
   git clone https://github.com/SyndicateProtocol/metabased-sequencer-chain-sc-modules-workshop.git
   cd metabased-sequencer-chain-sc-modules-workshop
   ```

2. Open the project in VS Code:

   ```bash
   code .
   ```

3. When prompted "Reopen in Container", click "Reopen in Container".
   Alternatively:

   - Press `F1` or `Cmd/Ctrl + Shift + P`
   - Type "Dev Containers: Reopen in Container"
   - Press Enter

4. Wait for the container to build. This might take a few minutes the first time.

#### Verifying the Setup

Once inside the dev container, open a terminal in VS Code (`Ctrl + ` ` or View -> Terminal) and run:

```bash
# Verify Foundry installation
forge --version

# Build the project
forge build
```

#### Using the Dev Container

- The container comes with Foundry and all required dependencies pre-installed
- Your local files are mounted in the container, so any changes you make are preserved
- VS Code extensions for Solidity development are automatically installed
- You can use the integrated terminal in VS Code to run commands

#### Troubleshooting Dev Container Setup

1. If the container fails to build:

   ```bash
   # In VS Code:
   1. Command Palette (Cmd/Ctrl + Shift + P)
   2. "Dev Containers: Rebuild Container"
   ```

2. If Foundry commands aren't working:

   ```bash
   foundryup
   ```

3. If you need to reset everything:

   ```bash
   # Close VS Code
   # Delete the .devcontainer folder
   # Reopen VS Code and rebuild the container
   ```

4. If you see permission issues:
   - Make sure Docker Desktop is running
   - Try running Docker Desktop with administrator privileges

### With Raw DockerFile (Medium Difficulty)

1. Install Docker Desktop:

   - [Windows](https://docs.docker.com/desktop/install/windows-install/)
   - [Mac](https://docs.docker.com/desktop/install/mac-install/)
   - [Linux](https://docs.docker.com/desktop/install/linux-install/)

2. Install Git:
   - [All platforms](https://git-scm.com/downloads)

#### Setup Instructions

1. Clone the repository:

   ```bash
   git clone https://github.com/SyndicateProtocol/metabased-sequencer-chain-sc-modules-workshop.git
   cd metabased-sequencer-chain-sc-modules-workshop
   ```

2. Build and start the container:

   ```bash
   docker compose up -d
   ```

3. Enter the container:

   ```bash
   docker compose exec metabased-dev bash
   ```

4. Verify the installation:

   ```bash
   # Inside the container
   forge --version
   cast --version
   anvil --version
   ```

5. copy `.env.example` to `.env` and fill in the required values.

```
cp .env.example .env
```

#### If you need to restart your environment:

```bash
# Exit the container first (if you're in it)
exit

# Then restart
docker compose down
docker compose up -d
```

#### Stopping the Environment

To stop the container:

```bash
docker compose down
```

To stop and remove all associated volumes:

```bash
docker compose down -v
```

#### Troubleshooting

1. If you get permission errors:

   ```bash
   # On Linux/Mac, you might need to run
   sudo chown -R $USER:$USER .
   ```

2. If the build fails:

   ```bash
   # Clean and rebuild
   docker compose down -v
   docker compose build --no-cache
   docker compose up -d
   ```

3. If Foundry commands aren't working:
   ```bash
   # Inside the container
   foundryup
   ```

### Using the Development Environment (Advanced)

- Git
- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Installation

1. Clone the repository:

   ```
   git clone https://github.com/SyndicateProtocol/metabased-sequencer-chain-sc-modules-workshop.git

   cd metabased-sequencer-chain-sc-modules-workshop
   ```

2. Install dependencies:

   ```
   forge install
   ```

3. Build the project:

   ```
   forge build
   ```

4. copy `.env.example` to `.env` and fill in the required values.

```
cp .env.example .env
```

## Creating a New Module

1. Create a new Solidity file in the `src/modules` directory.
2. Implement the `IsAllowed` interface:

   ```solidity
   import {IsAllowed} from "src/interfaces/IsAllowed.sol";

   contract YourNewModule is IsAllowed {
       function isAllowed(address proposer) external view override returns (bool) {
           // Your logic here
       }
   }
   ```

3. Implement your custom logic in the `isAllowed` function.

## Building and Deploying a Module

1. Build the module:

   ```
   forge build
   ```

2. Deploy the module (replace `YourNewModule` with your contract name):

3. Copy and script file to the `scripts` directory. Use one of the existing scripts as a template.

4. add a command to the `Makefile` to run your script. Use the section below as example.

## Using the Deployment scripts

In the workshop, we will use a fork of Metabased Testnet so you don't need to have ETH to deploy the contracts. The deployment scripts can be found `/script` folder.

Forking the Metabased Testnet:

```
make fork-metabased-testnet
```

Running the script in fork mode

```
make fork-allowlist-module-deploy-and-run
```
