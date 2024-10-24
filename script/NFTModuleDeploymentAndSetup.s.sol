// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {NFTOwnershipSequencingModule} from "src/NFTOwnershipSequencingModule.sol";
import {IMetabasedFactory} from "src/interfaces/IMetabasedFactory.sol";
import {IMetabasedSequencerChain} from "src/interfaces/IMetabasedSequencerChain.sol";

/**
 * @title NFTModuleDeploymentAndSetup
 * @notice This script deploys your L3 chain with NFT-based sequencing permissions
 * @dev Run this script with:
 *   make nft-module-deploy-and-run
 */
contract NFTModuleDeploymentAndSetup is Script {
    // Constants for the deployment
    address public constant FACTORY_ADDRESS = 0x9a0Ef1333681b357047282144dc06D7DAA1f76Ba;

    // Contract instances
    IMetabasedFactory public factory;
    NFTOwnershipSequencingModule public nftModule;
    IMetabasedSequencerChain public sequencerChain;

    // Configuration parameters
    uint256 public l3ChainId;
    address public nftAddress;
    uint256 public minimumNFTs;

    function setUp() public {
        console.log("====== Welcome to the Metabased L3 Chain Setup! ======");
        console.log("This script will help you set up your own L3 chain with NFT-based sequencing.");

        // These values can be overridden via environment variables
        l3ChainId = vm.envOr("L3_CHAIN_ID", uint256(31337)); // Default chain ID
        nftAddress = vm.envOr("NFT_ADDRESS", address(0x1234)); // Replace with your NFT address
        minimumNFTs = vm.envOr("MINIMUM_NFTS", uint256(1)); // Default to 1 NFT required

        console.log("====== Configuration Details ======");
        console.log("L3 Chain ID:", l3ChainId);
        console.log("Note: Chain ID must not be 0 (see EIP-3788)");
        console.log("NFT Contract Address:", nftAddress);
        console.log("Minimum NFTs Required:", minimumNFTs);
        console.log("==================================");

        // Validate chain ID
        require(l3ChainId != 0, "Chain ID cannot be 0. Please set a valid L3_CHAIN_ID environment variable.");
    }

    function run() public {
        // Get the deployer's address
        address deployer = vm.addr(vm.envUint("PRIVATE_KEY"));
        console.log("Deploying with address:", deployer);

        vm.startBroadcast();

        // Step 1: Connect to the factory
        console.log(" 1 Connecting to MetabasedFactory...");
        console.log("Factory Address:", FACTORY_ADDRESS);
        factory = IMetabasedFactory(FACTORY_ADDRESS);

        // Step 2: Deploy the NFT module
        console.log(" 2 Deploying NFTOwnershipSequencingModule...");
        console.log("Configuration:");
        console.log("   - NFT Contract:", nftAddress);
        console.log("   - Minimum NFTs:", minimumNFTs);
        nftModule = new NFTOwnershipSequencingModule(nftAddress, minimumNFTs);
        console.log("NFT Module deployed at:", address(nftModule));

        // Step 3: Create a new sequencer chain
        console.log(" 3 Creating new MetabasedSequencerChain...");
        console.log("Configuration:");
        console.log("- L3 Chain ID:", l3ChainId);
        address sequencerChainAddress = factory.createMetabasedSequencerChain(l3ChainId);
        sequencerChain = IMetabasedSequencerChain(sequencerChainAddress);
        console.log("Sequencer Chain deployed at:", sequencerChainAddress);

        // Step 4: Add the NFT module to the sequencer chain
        console.log(" 4 Adding NFT module to the chain's permission system...");
        sequencerChain.addRequireAnyCheck(address(nftModule), false);
        console.log("NFT module added to permissions!");

        // Verification steps
        console.log("====== Deployment Summary ======");
        console.log(" L3 Chain Details:");
        console.log("   - Chain ID:", sequencerChain.l3ChainId());
        console.log("   - Sequencer Chain:", address(sequencerChain));
        console.log(" Permission Module:");
        console.log("   - NFT Module Address:", address(nftModule));
        console.log("   - Required NFT:", nftAddress);
        console.log("   - Minimum NFTs:", minimumNFTs);

        // Verify the module is properly registered
        address[] memory requirements = sequencerChain.getAllRequirements(false);
        bool moduleFound = false;
        for (uint256 i = 0; i < requirements.length; i++) {
            if (requirements[i] == address(nftModule)) {
                moduleFound = true;
                break;
            }
        }
        console.log(" NFT Module Registration:", moduleFound ? "Successful" : "Failed");
        console.log("==============================");

        vm.stopBroadcast();

        // User instructions
        console.log(" What's Next?");
        console.log("1. Your L3 chain is ready for use!");
        console.log("2. Only addresses holding", minimumNFTs);
        console.log("or more NFTs from", nftAddress, "can sequence transactions");
        console.log("3. Test your setup by trying to sequence a transaction");
        console.log(" Important Addresses (save these):");
        console.log("- Sequencer Chain:", address(sequencerChain));
        console.log("- NFT Module:", address(nftModule));
        console.log(" Deployment complete! Happy sequencing! ");
    }
}
