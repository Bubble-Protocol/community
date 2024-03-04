// SPDX-License-Identifier: GPL-3.0
        
pragma solidity 0.8.24;

import {BubbleCommunityImplementation, IMemberRegistry, Mintable} from "../BubbleCommunity.sol";
import {BubbleCommunityNFT} from "../tokens/BubbleCommunityNFT.sol";
import {BubblePreGovernanceToken, Mint} from "../tokens/BubblePreGovernanceToken.sol";

uint constant TEST_MAX_SOCIALS = 5;

contract CommunityUser {

    BubbleCommunityImplementation uut;
    address public login = address(uint160(address(this)) + 1);

    constructor(BubbleCommunityImplementation uutAddress) {
        setUUT(uutAddress);
    }

    function setUUT(BubbleCommunityImplementation uutAddress) public {
        uut = uutAddress;
    }

    function initialise(Mintable token) external {
        uut.initialise(token);
    }
    
    function registerAsMember(bytes32[] memory socials) external {
        uut.registerAsMember(login, _dynToFixed(socials));
    }

    function registerMember(address member, bytes32[] memory socials) external {
        uut.registerMember(member, login, _dynToFixed(socials));
    }

    function updateSocials(bytes32[] memory newSocials) external {
        uut.updateSocials(_dynToFixed(newSocials));
    }

    function updateSocials(address member, bytes32[] memory newSocials) external {
        uut.updateSocials(member, _dynToFixed(newSocials));
    }

    function deregisterAsMember() external {
        uut.deregisterAsMember();
    }

    function deregisterMember(address member) external {
        uut.deregisterMember(member);
    }

    function banMember(address member) external {
        uut.banMember(member);
    }

    function banSocials(bytes32[] memory socials) external {
        uut.banSocials(socials);
    }

    function unbanMember(address member) external {
        uut.unbanMember(member);
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

    function mintToken(BubblePreGovernanceToken tokenContract, address member, uint value) public {
      tokenContract.mint(member, value);
    }

    function mintBatchToken(BubblePreGovernanceToken tokenContract, Mint[] memory batch) public {
      tokenContract.mintBatch(batch);
    }

    function setTokenMemberRegistry(BubblePreGovernanceToken tokenContract, IMemberRegistry reg) public {
      tokenContract.setMemberRegistry(reg);
    }

    function closeToken(BubblePreGovernanceToken tokenContract) public {
      tokenContract.close();
    }

    function mintNft(BubbleCommunityNFT nftContract) public returns (uint256) {
      return nftContract.mint();
    }

    function mintNft(BubbleCommunityNFT nftContract, address member) public returns (uint256) {
      return nftContract.mint(member);
    }

    function mintBatchNft(BubbleCommunityNFT nftContract, address[] memory members) public returns (uint256) {
      return nftContract.mintBatch(members);
    }

    function closeNft(BubbleCommunityNFT nftContract) public {
      nftContract.close();
    }

    function transferFrom(BubbleCommunityNFT nftContract, address from, address to, uint256 tokenId) public {
      nftContract.transferFrom(from, to, tokenId);
    }

    function approve(BubbleCommunityNFT nftContract, address to, uint256 tokenId) public {
      nftContract.approve(to, tokenId);
    }

    function setApprovalForAll(BubbleCommunityNFT nftContract, address operator, bool approved) public {
      nftContract.setApprovalForAll(operator, approved);
    }

    function _dynToFixed(bytes32[] memory dyn) internal pure returns (bytes32[TEST_MAX_SOCIALS] memory fixedArray) {
        require(dyn.length <= TEST_MAX_SOCIALS, "Input array too large");
        for (uint i=0; i<dyn.length; i++) {
            fixedArray[i] = dyn[i];
        }
        return fixedArray;
    }

    function onERC721Received(
        address /*operator*/,
        address /*from*/,
        uint256 /*tokenId*/,
        bytes calldata /*data*/
    ) external returns (bytes4) {
      return this.onERC721Received.selector;
    }
    
}
