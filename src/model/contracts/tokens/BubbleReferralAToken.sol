// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/access/Ownable.sol";
import "IMemberRegistry.sol";

/**
 * Bubble Protocol NFT designed to capture rewards for community members during promotions and referral schemes.
 * Tokens are non-transferable, designed instead to be converted to governance tokens or other rewards at a
 * later date.
 *
 * TODO: Check user is a member of the community before minting
 * TODO: Add claim flag?
 */
contract BubbleReferralAToken is ERC721, Ownable {

    uint256 private _nextTokenId;
    string private _URI;
    bool private _closed = false;
    IMemberRegistry private _memberRegistry;

    constructor(string memory name, string memory ticker, string memory uri, IMemberRegistry memberRegistry) ERC721(name, ticker) Ownable(msg.sender) {
      _URI = uri;
      _memberRegistry = memberRegistry;
    }

    /**
     * @dev mint a single token. Address must be registered to the member registry.
     */
    function mint(address member) public onlyOwner returns (uint256)
    {
      require(!_closed, 'round is closed');
      require(_memberRegistry.isMember(member), 'not a community member');
      require(balanceOf(member) == 0, 'already an owner');
      uint256 tokenId = _nextTokenId++;
      _safeMint(member, tokenId);
      return tokenId;
    }

    /**
     * @dev mint a batch of tokens for different members. All addresses must be registered 
     * to the member registry.
     */
    function mintBatch(address[] memory members) public onlyOwner returns (uint256)
    {
      require(!_closed, 'round is closed');
      uint256 firstToken = _nextTokenId;
      for (uint i=0; i<members.length; i++) {
        address member = members[i];
        require(_memberRegistry.isMember(member), 'not a community member');
        require(balanceOf(member) == 0, 'already an owner');
        _safeMint(member, _nextTokenId++, "");
      }
      return firstToken;
    }

    /**
     * @dev closes the round so no more tokens can be minted
     */
    function close() public onlyOwner {
      _closed = true;
    }

    /**
     * @dev returns `true` if this round is closed
     */
    function isClosed() external view returns (bool) {
      return _closed;
    }

    /**
     * @dev returns the member registry that ensures minting only for registered community members
     */
    function getMemberRegistry() external view returns (IMemberRegistry) {
      return _memberRegistry;
    }

    /**
     * @dev same uri for every token
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
      _requireOwned(tokenId);
      return _URI;
    }

    /**
     * @dev returns the number of tokens minted
     */
    function tokenCount() external view returns (uint) {
      return _nextTokenId;
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