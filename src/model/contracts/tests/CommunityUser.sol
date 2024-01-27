// SPDX-License-Identifier: GPL-3.0
        
pragma solidity 0.8.24;

import {BubbleCommunityImplementation} from "../BubbleCommunity.sol";
import {BubbleReferralAToken} from "../nfts/BubbleReferralAToken.sol";

contract CommunityUser {

    BubbleCommunityImplementation uut;

    constructor(BubbleCommunityImplementation uutAddress) {
        setUUT(uutAddress);
    }

    function setUUT(BubbleCommunityImplementation uutAddress) public {
        uut = uutAddress;
    }

    function initialise() external {
        uut.initialise();
    }
    
    function registerAsMember(bytes32[] memory socials) external {
        uut.registerAsMember(socials);
    }

    function registerMember(address member, bytes32[] memory socials) external {
        uut.registerMember(member, socials);
    }

    function updateSocials(bytes32[] memory oldSocials, bytes32[] memory newSocials) external {
        uut.updateSocials(oldSocials, newSocials);
    }

    function updateSocials(address member, bytes32[] memory oldSocials, bytes32[] memory newSocials) external {
        uut.updateSocials(member, oldSocials, newSocials);
    }

    function deregisterAsMember(bytes32[] memory socials) external {
        uut.deregisterAsMember(socials);
    }

    function deregisterMember(address member, bytes32[] memory socials) external {
        uut.deregisterMember(member, socials);
    }

    function banMember(address member, bytes32[] memory socials) external {
        uut.banMember(member, socials);
    }

    function banSocials(bytes32[] memory socials) external {
        uut.banSocials(socials);
    }

    function unbanSocials(bytes32[] memory socials) external {
        uut.unbanSocials(socials);
    }

    function registerNFT(address nftContract) external {
        uut.registerNFT(nftContract);
    }

    function deregisterNFT(address nftContract) external {
        uut.deregisterNFT(nftContract);
    }

    //
    // NFT API
    //

    function mint(BubbleReferralAToken nftContract, address member) public returns (uint256) {
      return nftContract.mint(member);
    }

    function mintBatch(BubbleReferralAToken nftContract, address[] memory members) public returns (uint256) {
      return nftContract.mintBatch(members);
    }

    function close(BubbleReferralAToken nftContract) public {
      nftContract.close();
    }

    function transferFrom(BubbleReferralAToken nftContract, address from, address to, uint256 tokenId) public {
      nftContract.transferFrom(from, to, tokenId);
    }

    function approve(BubbleReferralAToken nftContract, address to, uint256 tokenId) public {
      nftContract.approve(to, tokenId);
    }

    function setApprovalForAll(BubbleReferralAToken nftContract, address operator, bool approved) public {
      nftContract.setApprovalForAll(operator, approved);
    }


}