// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./BubbleCommunityNFT.sol";

/**
 * Bubble Protocol NFT designed to capture rewards for community members during promotions and referral schemes.
 * Tokens are non-transferable, designed instead to be converted to governance tokens or other rewards at a
 * later date.
 *
 * TODO: Check user is a member of the community before minting
 * TODO: Add claim flag?
 */
contract BubbleReferralAToken is BubbleCommunityNFT {

    constructor(string memory name, string memory ticker, string memory uri, IMemberRegistry memberRegistry)
    BubbleCommunityNFT(name, ticker, uri, 0, memberRegistry) {
    }

    /**
     * @dev referral tokens must be minted by admin
     */
    function mint() external pure override returns (uint256) {
      revert('permission denied');
    }

    /**
     * @dev tokens are non-transferable
     */
    function transferFrom(address /*from*/, address /*to*/, uint256 /*tokenId*/) public pure override {
      revert('tokens are non-transferable');
    }

    /**
     * @dev tokens are non-transferable
     */
    function approve(address /*to*/, uint256 /*tokenId*/) public pure override {
      revert('tokens are non-transferable');
    }

    /**
     * @dev tokens are non-transferable
     */
    function setApprovalForAll(address /*operator*/, bool /*approved*/) public pure override {
      revert('tokens are non-transferable');
    }

}