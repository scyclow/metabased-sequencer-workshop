// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

interface IMetabasedFactory {
    function createMetabasedSequencerChain(uint256 l3ChainId, address admin) external returns (address);

    event MetabasedSequencerChainCreated(uint256 indexed l3ChainId, address indexed metabasedSequencerChainAddress);
}
