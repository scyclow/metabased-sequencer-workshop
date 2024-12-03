// SPDX-License-Identifier: UNLICENSED


/*

    !!! DO NOT USE THIS CONTRACT IN PRODUCTION !!!

    This is exists purely as a thought experiment. No tests have been written,
    so actual functionality may be different than what is advertised. It might
    not even compile, for all I know


    HIGH SCORE

    - The Leader, at any point, may choose the SequencerAddress
    - Leadership is determined as follows:
        - At the start, any address may claim the Leadership for free
        - Once a Leader exists, another addres can claim the Leadership by posting
          any amount of ETH. This ETH goes to the old Leader, and the amount becomes
          the HighScore.
        - All subsequent Leadership changes require an address to post an ETH amount
          that is higher than the current HighScore
*/


pragma solidity 0.8.25;

import {IsAllowed} from "src/interfaces/IsAllowed.sol";


contract HighScoreModule is IsAllowed {
    address public Leader;
    address public SequencerAddress;
    uint256 public HighScore = 0;

    function claimLeadership() external payable {
        if (Leader != address(0)) {
            require(msg.value > HighScore, 'Insufficient HighScore Payment');
            (bool sent,) = payable(Leader).call{value: msg.value}('');
            require(sent, 'Failed to send');
        }
        Leader = msg.sender;
    }

    function setSequencerAddress(address newSequencer) external {
        require(msg.sender == Leader, 'Caller must be the Leader');
        SequencerAddress = newSequencer;
    }


    function isAllowed(address proposer) external view override returns (bool) {
        return proposer == SequencerAddress;
    }
}
