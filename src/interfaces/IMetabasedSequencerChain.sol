// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

interface IMetabasedSequencerChain {
    function l3ChainId() external view returns (uint256);
    function getAllRequirements(bool isRequired) external view returns (address[] memory);
    function addRequireAnyCheck(address module, bool isRequired) external;
}
