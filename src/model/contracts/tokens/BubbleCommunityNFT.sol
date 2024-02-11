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
contract BubbleCommunityNFT is ERC721, Ownable {

    uint256 private _nextTokenId;
    string private _URI;
    bool private _closed = false;
    IMemberRegistry private _memberRegistry;
    uint256 _maxTokens;

    constructor(string memory name, string memory ticker, string memory uri, uint256 maxTokens, IMemberRegistry memberRegistry) ERC721(name, ticker) Ownable(msg.sender) {
      _URI = uri;
      _memberRegistry = memberRegistry;
      _maxTokens = maxTokens > 0 ? maxTokens : type(uint256).max;
    }

    /**
     * @dev mint a single token. Address must be registered to the member registry.
     */
    function mint() external virtual returns (uint256) {
      return _mint(msg.sender);
    }

    /**
     * @dev mint a single token as admin. Address must be registered to the member registry.
     */
    function mint(address member) external onlyOwner returns (uint256) {
      return _mint(member);
    }

    /**
     * @dev mint a batch of tokens for different members. All addresses must be registered 
     * to the member registry.
     */
    function mintBatch(address[] memory members) public onlyOwner returns (uint256)
    {
      require(!_closed, 'round is closed');
      require(_nextTokenId + members.length <= _maxTokens, 'not enough tokens left');
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
     * Returns the maximum number of this NFT that can be minted
     */
    function totalCap() public view returns (uint256) {
      return _maxTokens;
    }

    /**
     * @dev closes the round so no more tokens can be minted
     */
    function close() external onlyOwner {
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
     * @dev sets the member registry contract
     */
    function setMemberRegistry(IMemberRegistry memberRegistry) external onlyOwner {
      _memberRegistry = memberRegistry;
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
     * @dev mint a single token, if there are any left. Address must be registered to the member registry.
     */
    function _mint(address member) internal returns (uint256)
    {
      require(!_closed, 'round is closed');
      require(_nextTokenId < _maxTokens, 'no tokens left');
      require(_memberRegistry.isMember(member), 'not a community member');
      require(balanceOf(member) == 0, 'already an owner');
      uint256 tokenId = _nextTokenId++;
      _safeMint(member, tokenId);
      return tokenId;
    }

}