// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {NFTOwnershipSequencingModule} from "src/NFTOwnershipSequencingModule.sol";
import {IMetabasedFactory} from "src/interfaces/IMetabasedFactory.sol";
import {IMetabasedSequencerChain} from "src/interfaces/IMetabasedSequencerChain.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

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
    address public admin;

    function setUp() public {
        console.log("====== Welcome to the Metabased L3 Chain Setup! ======");
        console.log("This script will help you set up your own L3 chain with NFT-based sequencing.");

        // These values can be overridden via environment variables
        l3ChainId = vm.envOr("L3_CHAIN_ID", uint256(31337)); // Default chain ID
        nftAddress = vm.envOr("NFT_ADDRESS", address(0x1234)); // Replace with your NFT address
        minimumNFTs = vm.envOr("MINIMUM_NFTS", uint256(1)); // Default to 1 NFT required

        admin = vm.envOr("ADMIN_ADDRESS", msg.sender);

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
        console.log("Deploying with address:", msg.sender);

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
        address sequencerChainAddress = factory.createMetabasedSequencerChain(l3ChainId, admin);
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

        // Interactive Demo Section
        console.log("\n=== Starting Interactive Demo ===");
        console.log("We'll simulate some transactions to demonstrate how NFT-based sequencing works\n");

        // Create test addresses and mint NFTs for demonstration
        address nftHolder = makeAddr("nftHolder");
        address nonHolder = makeAddr("nonHolder");
        address insufficientHolder = makeAddr("insufficientHolder");

        console.log("Test Addresses:");
        console.log("- NFT Holder (has required NFTs):", nftHolder);
        console.log("- Insufficient Holder (has some NFTs):", insufficientHolder);
        console.log("- Non Holder (has no NFTs):", nonHolder);

        // Mock NFT balances for demonstration
        vm.mockCall(nftAddress, abi.encodeWithSelector(IERC721.balanceOf.selector, nftHolder), abi.encode(minimumNFTs));
        vm.mockCall(
            nftAddress,
            abi.encodeWithSelector(IERC721.balanceOf.selector, insufficientHolder),
            abi.encode(minimumNFTs - 1)
        );
        vm.mockCall(nftAddress, abi.encodeWithSelector(IERC721.balanceOf.selector, nonHolder), abi.encode(0));

        // Demonstration of successful transactions
        console.log("\n=== Demonstrating Successful Transactions ===");
        console.log("Sending 3 transactions from address with enough NFTs...\n");

        vm.startPrank(nftHolder);
        bytes[] memory validTxs = new bytes[](3);
        for (uint256 i = 0; i < 3; i++) {
            validTxs[i] = abi.encode(string(abi.encodePacked("Transaction #", vm.toString(i + 1))));

            console.log("Sending Transaction #", i + 1);
            try sequencerChain.processTransaction(validTxs[i]) {
                console.log("[SUCCESS] Transaction accepted!");
                console.log("NFT Balance:", minimumNFTs);
                console.log("Required:", minimumNFTs);
            } catch {
                console.log("[ERROR] Transaction failed! (Unexpected)");
            }
            console.log("");
        }
        vm.stopPrank();

        // Demonstration with insufficient NFTs
        console.log("\n=== Demonstrating Transactions with Insufficient NFTs ===");
        console.log("Trying to send transaction from address with insufficient NFTs...\n");

        vm.startPrank(insufficientHolder);
        bytes memory insufficientTx = abi.encode("Insufficient NFTs Transaction");
        console.log("Attempting transaction from insufficient holder");
        try sequencerChain.processTransaction(insufficientTx) {
            console.log("[ERROR] Transaction went through! (This shouldn't happen)");
        } catch {
            console.log("[EXPECTED] Transaction blocked!");
            console.log("NFT Balance:", minimumNFTs - 1);
            console.log("Required:", minimumNFTs);
        }
        vm.stopPrank();

        // Demonstration with no NFTs
        console.log("\n=== Demonstrating Transactions with No NFTs ===");
        console.log("Trying to send transaction from address with no NFTs...\n");

        vm.startPrank(nonHolder);
        bytes memory noNftsTx = abi.encode("No NFTs Transaction");
        console.log("Attempting transaction from non-holder");
        try sequencerChain.processTransaction(noNftsTx) {
            console.log("[ERROR] Transaction went through! (This shouldn't happen)");
        } catch {
            console.log("[EXPECTED] Transaction blocked!");
            console.log("NFT Balance: 0 Required:", minimumNFTs);
        }
        vm.stopPrank();

        console.log("\n=== Demo Key Takeaways ===");
        console.log("1. Addresses must hold at least", minimumNFTs, "NFTs to sequence transactions");
        console.log("2. Holding insufficient NFTs results in transaction rejection");
        console.log("3. NFT balance is checked in real-time for each transaction");

        console.log("\n=== Try it yourself ===");
        console.log("1. Required NFT Contract:", nftAddress);
        console.log("2. Minimum NFTs Required:", minimumNFTs);
        console.log("3. Submit transactions: sequencerChain.processTransaction(bytes)");

        console.log("\n=== Demo Complete! ===");
    }
}
