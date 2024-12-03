// SPDX-License-Identifier: UNLICENSED


/*

    !!! DO NOT USE THIS CONTRACT IN PRODUCTION !!!

    This is exists purely as a thought experiment. No tests have been written,
    so actual functionality may be different than what is advertised. It might
    not even compile, for all I know


    NUCLEAR WAR

    - Nine Leaders are chosen at instantiation
    - All Leaders act as Sequencer addresses
    - At any point, a Leader can nuke another Leader, removing them from the
      Leader list.
    - Completing a nuke operation takes 12 minutes, during which time the target
      Leader can retaliate.
    - If all Leaders are eliminated, there will be no valid proposer for isAllowed,
      and no one will be able to sequence.
*/


pragma solidity 0.8.25;

import {IsAllowed} from "src/interfaces/IsAllowed.sol";


contract HighScoreModule is IsAllowed {
    mapping(address => bool) public LeaderList;

    enum MissleTargetStatus {
        Dormant,
        Fired,
        Completed
    }

    struct NuclearMissle {
        address target;
        MissleTargetStatus status;
        uint256 firedAt;
    }

    uint8 missleCount;

    mapping(uint256 => NuclearMissle) public Missles;

    address public SequencerAddress;

    constructor(address[9] leaders) {
        for (address l; l < 9; l++) {
            LeaderList[leaders[l]] = true;
        }
    }


    function fireMissle(address target) external public returns (uint8) {
        require(LeaderList[msg.sender], 'Only a Leader can fire a nuke');

        uint8 missleId = missleCount
        Missles[missleId].status = MissleTargetStatus.Fired;
        Missles[missleId].target = target;
        Missles[missleId].firedAt = block.timestamp;

        missleCount++;

        return missleId;
    }

    function completeMissleLaunch(uint8 missleId) external public {
        require(NuclearMissle[missleId].status == Fired, 'Can only complete a Fired missle');
        require(block.timestamp - NuclearMissle[missleId].timestamp >= 12 minutes, 'Must wait 12 minutes to complete missle launch');
        NuclearMissle[missleId].status = MissleTargetStatus.Completed;
        LeaderList[NuclearMissle[missleId].target] = false;
    }


    function isAllowed(address proposer) external view override returns (bool) {
        return proposer == LeaderList[msg.sender];
    }
}
