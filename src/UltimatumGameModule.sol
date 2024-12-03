// SPDX-License-Identifier: UNLICENSED


/*

    !!! DO NOT USE THIS CONTRACT IN PRODUCTION !!!

    This is exists purely as a thought experiment. No tests have been written,
    so actual functionality may be different than what is advertised. It might
    not even compile, for all I know


    ULTIMATUM GAME

    - A Proposer and a Responder are chosen at instantiation
    - At any point, the Proposer may propose a SequencerAddress
    - The Responder has 1 hour to accept the proposal
    - If the proposal is not accepted within 1 hour, it may no longer be accepted,
      and my be rejected by anyone.
    - If a proposal fails, then blocks can no longer be sequenced

*/


pragma solidity 0.8.25;

import {IsAllowed} from "src/interfaces/IsAllowed.sol";


contract UltimatumGameModule is IsAllowed {
    address public Proposer;
    address public Responder;


    enum Status {
        Proposed,
        Accepted,
        Rejected
    }

    struct Proposal {
        address sequencer;
        uint256 timestamp;
        Status status;
    }

    Proposal public SequencerAddressProposal;

    constructor(address proposer, address responder) {
        Proposer = proposer;
        Responder = responder;

        SequencerAddressProposal.status = Status.Accepted;
    }


    function propose(address sequencer) external {
        require(msg.sender == Proposer, 'Only the Proposer can propose');
        require(SequencerAddressProposal.status == Status.Accepted, 'A proposal cannot be made');

        SequencerAddressProposal.sequencer = sequencer;
        SequencerAddressProposal.timestamp = block.timestamp;
        SequencerAddressProposal.status = Status.Proposed;
    }

    function accept() external {
        require(msg.sender == Responder, 'Only the Responder can accept the proposal');
        require(block.timestamp - SequencerAddressProposal.timestamp <= 1 hours, 'The proposal can no longer be accepted');
        require(SequencerAddressProposal.status == Proposed, 'The proposal cannot be accepted');

        SequencerAddressProposal.status = Status.Accepted;
    }

    function reject() external {
        require(SequencerAddressProposal.status == Status.Proposed, 'The proposal cannot be rejected');
        if (block.timestamp - SequencerAddressProposal.timestamp < 1 hours) {
            require(msg.sender == Responder, 'Only the Responder can reject the proposal');
        }

        SequencerAddressProposal.status = Status.Rejected;
    }


    function isAllowed(address proposer) external view override returns (bool) {
        return proposer == SequencerAddressProposal.sequencer && SequencerAddressProposal.status == Status.Accepted;
    }
}
