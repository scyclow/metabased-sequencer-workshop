// SPDX-License-Identifier: UNLICENSED


/*

    !!! DO NOT USE THIS CONTRACT IN PRODUCTION !!!

    This is exists purely as a thought experiment. No tests have been written,
    so actual functionality may be different than what is advertised. It might
    not even compile, for all I know


    HARBERGER TAX

    - The Leader, at any point, may choose the SequencerAddress
    - The Leader must set a LeadershipPrice at which they are willing to sell the Leadership
    - At any point, another address may purchase the Leadership for that price
    - The Leader must pay a tax equal to 5% of the LeadershipPrice, annualized + paid weekly,
      to retain the Leadership.
    - All taxes go to the Treasury

*/


pragma solidity 0.8.25;

import {IsAllowed} from "src/interfaces/IsAllowed.sol";


contract HarbergerTaxModule is IsAllowed {
    address public Leader;
    address public SequencerAddress;
    address public Treasury;
    uint256 public LeadershipPrice

    uint256 public taxLastpaid;
    uint256 public lastPriceUpdate;

    uint256 constant public taxRateBps = 500;

    constructor(address treasury) {
        Treasury = treasury;
    }

    function setLeadershipPrice(uint256 price) external {
        require(msg.sender == Leader, 'Only the Leader can set the LeadershipPrice')
        LeadershipPrice = price;
        lastPriceUpdate = block.timestamp;
    }

    function buyLeadership() external payable {
        require(msg.value >= LeadershipPrice, 'Payment amount too low');

        (bool sent,) = payable(Leader).call{value: msg.value}('');
        require(sent, 'Failed to send');

        Leader = msg.sender;
    }

    function payTax() external payable {
        require(msg.value >= LeadershipPrice * taxRateBps / 520000, 'Tax not high enough');
        require(block.timestamp - lastPriceUpdate > 1 hours, 'Must wait at least 1 hour after updating price');
        taxLastpaid = block.timestamp;

        (bool sent,) = payable(Treasury).call{value: msg.value}('');
        require(sent, 'Failed to send');
    }

    function claimLeadership() external payable {
        require(block.timestamp - taxLastpaid > 1 weeks, 'Leadership cannot be claimed');
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
