// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {AllowlistSequencingModule} from "src/AllowlistSequencingModule.sol";
import {IMetabasedFactory} from "src/interfaces/IMetabasedFactory.sol";
import {IMetabasedSequencerChain} from "src/interfaces/IMetabasedSequencerChain.sol";

/**
 * @title AllowlistModuleDeploymentAndSetup
 * @notice This script deploys your L3 chain with an allowlist-based sequencing module
 * @dev Run this script with:
 *   make allowlist-module-deploy-and-run
 */
contract AllowlistModuleDeploymentAndSetup is Script {
    // Constants for the deployment
    address public constant FACTORY_ADDRESS = 0x9a0Ef1333681b357047282144dc06D7DAA1f76Ba;

    // Contract instances
    IMetabasedFactory public factory;
    AllowlistSequencingModule public allowlistModule;
    IMetabasedSequencerChain public sequencerChain;

    // Configuration parameters
    uint256 public l3ChainId;
    address public admin;
    address[] public initialAllowedUsers;

    function setUp() public {
        console.log("====== Welcome to the Metabased L3 Chain Setup! ======");
        console.log("This script will help you set up your L3 chain with allowlist-based sequencing.");

        // Get configuration from environment variables
        admin = vm.envOr("ADMIN_ADDRESS", msg.sender);
        l3ChainId = vm.envOr("L3_CHAIN_ID", uint256(31337));

        // Initial allowed users. Add to the array what addresses you want to allowlist initially
        initialAllowedUsers = [msg.sender];

        console.log("====== Configuration Details ======");
        console.log("L3 Chain ID:", l3ChainId);
        console.log("Note: Chain ID must not be 0 (see EIP-3788)");
        console.log("Admin Address:", admin);
        console.log("Number of Initial Allowed Users:", initialAllowedUsers.length);
        console.log("==================================");

        // Validate chain ID
        require(l3ChainId != 0, "Chain ID cannot be 0. Please set a valid L3_CHAIN_ID environment variable.");
    }

    function run() public {
        console.log("Deploying with address:", msg.sender);

        vm.startBroadcast();

        // Step 1: Connect to the factory
        console.log("STEP 1: Connecting to MetabasedFactory...");
        console.log("Factory Address:", FACTORY_ADDRESS);
        factory = IMetabasedFactory(FACTORY_ADDRESS);

        // Step 2: Deploy the allowlist module
        console.log("STEP 2: Deploying AllowlistSequencingModule...");
        console.log("Configuration:");
        console.log("   - Admin Address:", admin);
        allowlistModule = new AllowlistSequencingModule(admin);
        console.log("SUCCESS: Allowlist Module deployed at:", address(allowlistModule));

        // Step 3: Create a new sequencer chain
        console.log("STEP 3: Creating new MetabasedSequencerChain...");
        console.log("Configuration:");
        console.log("   - L3 Chain ID:", l3ChainId);
        address sequencerChainAddress = factory.createMetabasedSequencerChain(l3ChainId, admin);
        sequencerChain = IMetabasedSequencerChain(sequencerChainAddress);
        console.log("SUCCESS: Sequencer Chain deployed at:", sequencerChainAddress);

        // Step 4: Add the allowlist module to the sequencer chain
        console.log("STEP 4: Adding allowlist module to the chain's permission system...");
        sequencerChain.addRequireAnyCheck(address(allowlistModule), false);
        console.log("SUCCESS: Allowlist module added to permissions!");

        // Step 5: Add initial allowed users if any
        if (initialAllowedUsers.length > 0) {
            console.log("STEP 5: Adding initial allowed users...");
            for (uint256 i = 0; i < initialAllowedUsers.length; i++) {
                console.log("   Adding user:", initialAllowedUsers[i]);
                allowlistModule.addToAllowlist(initialAllowedUsers[i]);
            }
            console.log("SUCCESS: Initial users added to allowlist!");
        }

        // Verification steps
        console.log("====== Deployment Summary ======");
        console.log("L3 Chain Details:");
        console.log("   - Chain ID:", sequencerChain.l3ChainId());
        console.log("   - Sequencer Chain:", address(sequencerChain));
        console.log("Permission Module:");
        console.log("   - Allowlist Module:", address(allowlistModule));
        console.log("   - Admin:", allowlistModule.admin());

        // Verify the module is properly registered
        address[] memory requirements = sequencerChain.getAllRequirements(false);
        bool moduleFound = false;
        for (uint256 i = 0; i < requirements.length; i++) {
            if (requirements[i] == address(allowlistModule)) {
                moduleFound = true;
                break;
            }
        }
        console.log("Allowlist Module Registration:", moduleFound ? "Successful" : "Failed");
        console.log("==============================");

        vm.stopBroadcast();

        // Interactive Demo Section
        console.log("\n=== Starting Interactive Demo ===");
        console.log("We'll simulate some transactions to demonstrate how the allowlist works\n");

        // Create some test addresses
        address allowedUser = admin; // Already in allowlist
        address randomUser = address(0x678);

        console.log("Test Addresses:");
        console.log("- Allowed User:", allowedUser);
        console.log("- Random User:", randomUser);

        // Demonstration of successful transactions
        console.log("\n=== Demonstrating Successful Transactions ===");
        console.log("Sending 5 transactions from allowed address...\n");

        vm.startPrank(admin);

        bytes[] memory validTxs = new bytes[](5);
        for (uint256 i = 0; i < 5; i++) {
            validTxs[i] = abi.encode(string(abi.encodePacked("Transaction #", vm.toString(i + 1))));

            console.log("Sending Transaction #", i + 1);
            try sequencerChain.processTransaction(validTxs[i]) {
                console.log("[SUCCESS] Transaction accepted!");
            } catch {
                console.log("[ERROR] Transaction failed! (Unexpected)");
            }
            console.log("");
        }

        vm.stopPrank();

        // Demonstration of failed transactions
        console.log("\n=== Demonstrating Failed Transactions ===");
        console.log("Trying to send 2 transactions from unauthorized address...\n");

        vm.startPrank(randomUser);
        bytes[] memory invalidTxs = new bytes[](2);
        for (uint256 i = 0; i < 2; i++) {
            invalidTxs[i] = abi.encode(string(abi.encodePacked("Unauthorized Transaction #", vm.toString(i + 1))));

            console.log("Attempting Transaction #", i + 1, "from unauthorized address");
            try sequencerChain.processTransaction(invalidTxs[i]) {
                console.log("[ERROR] Transaction went through! (This shouldn't happen)");
            } catch {
                console.log("[EXPECTED] Transaction blocked!");
                console.log("          Reason: Address not in allowlist");
            }
            console.log("");
        }
        vm.stopPrank();

        vm.startPrank(admin);
        // Let's add the random user to allowlist and try again
        console.log("\n=== Adding previously unauthorized user to allowlist ===");
        allowlistModule.addToAllowlist(randomUser);

        vm.stopPrank();

        vm.startPrank(randomUser);
        console.log("\n=== Trying one more time with newly authorized user ===");
        try sequencerChain.processTransaction(invalidTxs[0]) {
            console.log("[SUCCESS] Transaction accepted after being added to allowlist!");
        } catch {
            console.log("[ERROR] Transaction failed! (Unexpected)");
        }
        vm.stopPrank();

        console.log("\n=== Demo Key Takeaways ===");
        console.log("1. Only addresses in the allowlist can submit transactions");
        console.log("2. Unauthorized attempts are automatically rejected");
        console.log("3. Adding an address to allowlist immediately grants sequencing permissions");

        console.log("\n=== Demo Complete! ===");
    }
}
