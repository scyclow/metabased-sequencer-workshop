# Metabased Sequencer Chain Modules Workshop

## Overview

The Metabased Sequencer Chain is a modular protocol for sequencing transactions in Layer 3 chains. It uses a flexible system of modules to determine who is allowed to sequence transactions.

## Key Components

1. **MetabasedSequencerChain**: The core contract for sequencing transactions.
2. **RequireListManager**: Manages the list of modules that determine sequencing permissions.
3. **Modules**: Implement the `IsAllowed` interface to define custom sequencing criteria.

## Getting Started

### Prerequisites

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

2. Run tests (if you've written tests for your module):

   ```
   forge test
   ```

3. Deploy the module (replace `YourNewModule` with your contract name):

   ```
   forge create --rpc-url <your_rpc_url> --private-key <your_private_key> src/modules/YourNewModule.sol:YourNewModule --constructor-args <arg1> <arg2>
   ```

4. After deployment, add the module's address to the RequireListManager using the `addRequireAllCheck` or `addRequireAnyCheck` function, depending on your requirements.

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
