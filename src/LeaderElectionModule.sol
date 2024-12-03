// SPDX-License-Identifier: UNLICENSED


/*

    !!! DO NOT USE THIS CONTRACT IN PRODUCTION !!!

    This is exists purely as a thought experiment. No tests have been written,
    so actual functionality may be different than what is advertised. It might
    not even compile, for all I know


    LEADER ELECTION

    - The contract is instantiated with a pool of 7 Voters
    - The Leader can choose the SequencerAddress at any time
    - At any point, a majority vote can overthrow the Leader
        - This will nullify the current SequencerAddress
        - This will trigger a new leader election, in which a majority
          vote must pick a new Leader
    - Overthrowing the Leader will nullify the SequencerAddress, so no blocks
      can be sequenced while a leader election is in progress

*/


pragma solidity 0.8.25;

import {IsAllowed} from "src/interfaces/IsAllowed.sol";


contract LeaderElectionModule is IsAllowed {
    address public Leader;
    address public SequencerAddress;

    address[7] public VoterList;
    mapping(address => bool) public Voters;
    mapping(address => bool) public overthrowVotes;
    mapping(address => address) public newLeaderVotes;

    constructor(address[7] voters) {
        VoterList = voters;

        for (uint8 v; v < 7; v++) {
            Voters[voters[v]] = true;
        }

        Leader = voters[0]
    }

    function overthrowVote(bool overthrow) external public {
        require(Voters[msg.sender], 'Only Voters can vote');
        require(Leader != address(0), 'No Leader to overthrow');

        overthrowVotes[msg.sender] = overthrow;

        if (totalOverthrowVotes() > 3) {
            _overthrow();
        }
    }


    function newLeaderVote(address newLeader) external public {
        require(Voters[msg.sender], 'Only Voters can vote');
        require(Leader == address(0), 'Must overthrow current Leader');
        newLeaderVotes[msg.sender] = newLeader;

        if (countVotes(newLeader) > 3) {
            _setLeader(newLeader);
        }
    }


    function totalOverthrowVotes() public view returns (uint8) {
        uint8 overthrowCount;
        for (uint8 v; v < 7; v++) {
            if (overthrowVotes[VoterList[v]]) {
                overthrowCount++;
            }
        }

        return overthrowCount;
    }


    function countVotes(address addr) public view returns (uint8) {
        uint8 voteCount;
        for (uint8 v; v < 7; v++) {
            if (newLeaderVotes[VoterList[v]] == addr) {
                voteCount++;
            }
        }

        return voteCount;
    }



    function _setLeader(newLeader) private {
        Leader = newLeader;
        for (uint8 v; v < 7; v++) {
            newLeaderVotes[VoterList[v]] = address(0);
        }
    }

    function _overthrow() private {
        SequencerAddress = address(0);
        Leader = address(0);
        for (uint8 v; v < 7; v++) {
            overthrowVotes[VoterList[v]] = false;
        }
    }




    function setSequencerAddress(address newSequencer) external {
        require(msg.sender == Leader, 'Caller must be the Leader');
        SequencerAddress = newSequencer;
    }


    function isAllowed(address proposer) external view override returns (bool) {
        return proposer == SequencerAddress;
    }
}
