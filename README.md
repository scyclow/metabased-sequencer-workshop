# Metabased Sequencer Chain Modules Workshop

## Overview

The Metabased Sequencer Chain is a modular protocol for sequencing transactions in Layer 3 chains. It uses a flexible system of modules to determine who is allowed to sequence transactions.

## Key Components

1. **MetabasedSequencerChain**: The core contract for sequencing transactions.
2. **RequireListManager**: Manages the list of modules that determine sequencing permissions.
3. **Modules**: Implement the `IsAllowed` interface to define custom sequencing criteria.

## Getting Started

### With Docker

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

### Using the Development Environment

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
