// SPDX-License-Identifier: UNLICENSED


/*

    !!! DO NOT USE THIS CONTRACT IN PRODUCTION !!!

    This is exists purely as a thought experiment. No tests have been written,
    so actual functionality may be different than what is advertised. It might
    not even compile, for all I know


    RANDOM

    - A list of potential sequencers is defined at contract instantiation
    - All sequencers must post a bond
    - Every block, a random participant from the list is chosen
    - If a block isn't correctly sequenced, the sequencer responsible for that block gets slashed
    - Governance regarding who is in the sequencer list is TBD
    - How can one tell if a block was correctly sequenced?
*/


pragma solidity 0.8.25;

import {IsAllowed} from "src/interfaces/IsAllowed.sol";


contract RandomModule is IsAllowed {
    uint256[] public slots;
    uint256 public TOTAL_SLOTS;
    uint256 public BOND_AMOUNT = 1 ether;
    mapping(address => uint256) public bondBalance;
    mapping(uint256 => bool) public slashed;

    constructor(uint256[] sequencerList) {
        TOTAL_SLOTS = sequencerList.length;
        slots = sequencerList;
    }

    function isAllowed(address proposer) external view override returns (bool) {
        address sequencer = sequencerForBlock(block.number);
        return (
            proposer == sequencer
            && bondBalance[sequencer] >= BOND_AMOUNT
        );
    }


    function sequencerForBlock(uint256 blockNumber) external view returns (address) {
        uint256 slot = uint256(blockhash(blockNumber - 1)) % TOTAL_SLOTS;
        return sequencerList[slot];
    }


    function postBond() external payable {
        bondBalance[msg.sender] += msg.value;
    }

    function slash(uint256 blockNumber) external {
        if (wasBlockSequenced(blockNumber) && !slashed[blockNumber]) {
            address sequencer = sequencerForBlock(blockNumber);
            bondBalance[sequencer] -= BOND_AMOUNT;
            payable(msg.sender).call{ value: BOND_AMOUNT, gas: 30_000 }(new bytes(0));
            slashed[blockNumber] = true;
        }
    }

    function wasBlockSequenced(uint256 blockNumber) external view returns (bool) {
        // How can you tell if a block was correctly sequenced?
        return true;
    }
}
