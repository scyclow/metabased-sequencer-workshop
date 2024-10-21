// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {IsAllowed} from "src/interfaces/IsAllowed.sol";

contract YourNewModule is IsAllowed {
    function isAllowed(address proposer) external view override returns (bool) {
        // Your logic here
    }
}
