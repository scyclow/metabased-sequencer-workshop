// SPDX-License-Identifier: UNLICENSED




/*

    !!! DO NOT USE THIS CONTRACT IN PRODUCTION !!!

    This is exists purely as a thought experiment. No tests have been written,
    so actual functionality may be different than what is advertised. It might
    not even compile, for all I know


    KING OF THE HILL

    - The King, at any point, may choose the SequencerAddress
    - At any point, any address may claim the Kingship
*/


pragma solidity 0.8.25;

import {IsAllowed} from "src/interfaces/IsAllowed.sol";


contract KingOfTheHillModule is IsAllowed {
    address public King;
    address public SequencerAddress;

    function claimKingship() external {
        King = msg.sender;
    }

    function setSequencerAddress(address newSequencer) external {
        require(msg.sender == King, 'Caller must be the King');
        SequencerAddress = newSequencer;
    }


    function isAllowed(address proposer) external view override returns (bool) {
        return proposer == SequencerAddress;
    }
}
