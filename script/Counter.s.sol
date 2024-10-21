// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
// import {NFTOwnershipSequencingModule} from "../src/NFTOwnershipSequencingModule.sol";

// TODO: Implement the DeploymentAndSetupScript
contract DeploymentAndSetupScript is Script {
    // NFTOwnershipSequencingModule public NFTOwnershipSequencingModule;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // NFTOwnershipSequencingModule = new NFTOwnershipSequencingModule();

        vm.stopBroadcast();
    }
}
