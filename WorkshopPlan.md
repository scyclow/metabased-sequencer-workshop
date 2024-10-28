# Workshop Plan: Creating a Module for the Metabased Sequencer Chain

## Duration: 1 hour and 30 minutes

### I. Introduction (5 minutes)

- Welcome participants and introduce yourself
- Briefly explain the Metabased Sequencer Chain protocol from Smart Contract Perpective
- Overview of the workshop objectives
  -- Understand that the created a chain from a smart contract
  -- they can customize the chain behavior via modules
  -- they will understand the tx flow in this new paradigm.

### II. Protocol Overview (10 minutes) Gus

- Explain the core components: MetabasedSequencerChain and RequireListManager
- Discuss the concept of modules and their role in the protocol
- Briefly show module example, explain deep dive happens later in the workshop

### III. Setting Up the Development Environment (10 minutes)

- Ensure all participants have Git and Foundry installed - (Docker container for faster installation)
 TODO: create a video of the docker installation so participants have it before the workshop
 Also do on the day LIVE so they can see the process
- Clone the protocol repository
- Walk through the project structure

### IV. Understanding the IsAllowed Interface (5 minutes)

- Explain the IsAllowed interface and its importance
- Discuss how modules implement this interface

### V. Show module example - NFT-based Module (10 minutes)

- Introduce the concept of an NFT-based sequencing module
- Show `NFTOwnershipSequencingModule`
  - Show the constructor
  - Point to where the `isAllowed` function is called
  - Explain each step of the implementation
- Ask whether participants have any questions

### VI. Create Own Module (20 minutes)

- Elicit Participants to Write a Module
- One idea for module: if one address has an ERC20 min balance they can sequence
- Another idea: if an address has x amount of staked ERC20 tokens they can sequence

### VII. Deploying the Module (15 minutes)

- Explain the deployment process
- Demonstrate how to deploy the module using Foundry

### VIII. Q&A and Conclusion (15 minutes)

- Open the floor for questions
- Recap the key points of the workshop
- Provide resources for further learning - Link to Metabased website, Github, etc.

### Materials Needed:

- Slides for the introduction and protocol overview (create visuals how the modules connect with the sequencers in the L3 chains) - Sheldon will create

- Show the steps how to create the core contract for the L3 and how to connect the module and send the tx. Make them see the "magic" of the process.

- Add fake txs on a loop to show the sequencer in action
  -- Example: The txs that will meet the criterion of the module.
  A batch of txs that will not meet the criterion of the module

- Pre-prepared code snippets such as script to deploy the module
