// SPDX-License-Identifier: UNLICENSED


/*

    !!! DO NOT USE THIS CONTRACT IN PRODUCTION !!!

    This is exists purely as a thought experiment. No tests have been written,
    so actual functionality may be different than what is advertised. It might
    not even compile, for all I know


    PIRATE GAME

    - The game starts with five Pirates, one of whom is the captain
    - The Captain can propose the SequencerAddress at any time
    - After a proposal, the Pirates vote
        - If a proposal does not get a majority vote, the Captain is thrown
          overboard, and the second in command becomes Captain
        - Yays have the tie breaking vote
    - Pirates can throw the Captain overboard with a majority vote at any time

*/


pragma solidity 0.8.25;

import {IsAllowed} from "src/interfaces/IsAllowed.sol";


contract PirateGameModule is IsAllowed {
    enum Status {
        Proposed,
        Accepted,
        Rejected
    }

    enum VoteValue {
        NoVote,
        Yay,
        Nay
    }

    struct Proposal {
        address sequencer;
        Status status;
    }

    Proposal public SequencerAddressProposal;

    address[5] public PirateList;
    mapping(address => bool) public Pirates;
    mapping(address => VoteValue) public Votes;

    constructor(address[5] pirates) {
        for (uint8 p; p < 5; p++) {
            Pirates[pirates[v]] = true;
        }
        PirateList = pirates;
        SequencerAddressProposal.status = Status.Accepted;
    }


    function Captain() public view returns (address) {
        return PirateList[PirateList.length - 1];
    }

    function propose(address sequencer) external {
        require(msg.sender == Captain(), 'Only the Captain can propose');
        require(
            proposed.status == Status.Accepted || proposed.status == Status.Rejected,
            'Another proposal cannot be made'
        );

        proposed.sequencer = sequencer;
        proposed.status = Status.Proposed;

        Votes[msg.sender] = VoteValue.Yay;
    }

    function vote(bool v) external {
        require(PirateList[msg.sender], 'Only active Pirates can vote');

        if (v) Votes[msg.sender] = VoteValue.Yay;
        else Votes[msg.sender] = VoteValue.Nay;

        if (countVotes(VoteValue.Yay) >= PirateList.length / 2) _passVote()
        else if (countVotes(VoteValue.Nay) > PirateList.length / 2) _rejectVote();
    }

    function countVotes(VoteValue val) public view returns (uint8) {
        uint8 voteCount;
        for (uint8 v; v < PirateList.length; v++) {
            if (Votes[PirateList[v]] == val) {
                voteCount++;
            }
        }

        return voteCount;
    }

    function _passVote() private {
        SequencerAddressProposal.status = Status.Accepted;
        _nullifyVotes();
    }

    function _rejectVote() private {
        _nullifyVotes();
        _throwCaptainOverboard();
        SequencerAddressProposal.status = Status.Rejected;
        SequencerAddressProposal.sequencer = address(0);
    }

    function _nullifyVotes() private {
        for (uint8 v; v < PirateList.length; v++) {
            Votes[PirateList[v]] = VoteValue.NoVote
        }
    }

    function _throwCaptainOverboard() private {
        address formerCaptain = PirateList.pop();
        Pirates[formerCaptain] = false;
    }

    function isAllowed(address proposer) external view override returns (bool) {
        return proposer == SequencerAddressProposal.sequencer && SequencerAddressProposal.status == Status.Accepted;
    }
}
