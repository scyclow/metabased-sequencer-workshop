// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import {IsAllowed} from "src/interfaces/IsAllowed.sol";

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
}

/**
 * @title NFTOwnershipSequencingModule
 * @dev This contract allows sequencing based on the caller's NFT ownership.
 */
contract NFTOwnershipSequencingModule is IsAllowed {
    /// @notice The address of the ERC721 NFT contract.
    address public immutable nftAddress;
    /// @notice The minimum number of NFTs required to be allowed.
    uint256 public immutable minimumOwnership;

    /**
     * @dev Sets the NFT address and minimum ownership required.
     * @param _nftAddress The address of the ERC721 NFT contract.
     * @param _minimumOwnership The minimum number of NFTs required to be allowed.
     */
    constructor(address _nftAddress, uint256 _minimumOwnership) {
        require(_nftAddress != address(0), "NFTOwnershipSequencingModule: zero address");
        require(_minimumOwnership > 0, "NFTOwnershipSequencingModule: zero minimum ownership");

        nftAddress = _nftAddress;
        minimumOwnership = _minimumOwnership;
    }

    error InsufficientNFTOwnership();

    /**
     * @notice Checks if the caller is allowed based on their NFT ownership.
     * @param proposer The address of the proposer to check.
     * @return bool indicating if the proposer is allowed.
     */
    function isAllowed(address proposer) external view override returns (bool) {
        IERC721 nft = IERC721(nftAddress);
        if (nft.balanceOf(proposer) < minimumOwnership) {
            revert InsufficientNFTOwnership();
        }
        return true;
    }
}
