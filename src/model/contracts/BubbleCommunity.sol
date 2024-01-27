// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/Proxy.sol";
import "IMemberRegistry.sol";
import "../EternalStorage.sol";


/**
 * The registry data definition. Non-upgradeable eternal storage.
 */
abstract contract BubbleCommunityStorage is EternalStorage, AccessControl {

  uint internal _memberCount;
  mapping (address => bool) internal _members;
  mapping (bytes32 => address) internal _socials;
  address[] internal _nfts;

  bytes32 internal _endOfStorage = END_OF_STORAGE;

}


/**
 * The community storage contract. The eternal data plus getter functions. Non-upgradeable.
 */
contract BubbleCommunity is BubbleCommunityStorage, IMemberRegistry, Proxy {

  /**
   * @dev required by EternalStorage
   */
  constructor() {
    _initialiseStorageContract();
  }

  /**
   * @dev required by Proxy
   */
  function _implementation() internal view override returns (address) {
    return implementationContract;
  }

  /**
   * @dev returns `true` if the given address is a registered member of the community
   */
  function isMember(address member) external view override returns (bool) {
    return _members[member];
  }

  /**
   * @dev returns the owner address of the given social media username hash.
   */
  function getUserAddress(bytes32 usernameHash) external view override returns (address) {
    return _socials[usernameHash];
  }

  /**
   * @dev returns a list of all the registered nft contracts
   */
  function getMemberCount() external view returns (uint) {
    return _memberCount;
  }

  /**
   * @dev returns `true` if the given contract address is a registered NFT
   */
  function hasNFT(address nftContract) public view returns (bool) {
    for (uint i=0; i<_nfts.length; i++) {
      if (_nfts[i] == nftContract) return true;
    }
    return false;
  }

  /**
   * @dev returns a list of all the registered nft contracts
   */
  function getNFTs() external view returns (address[] memory) {
    return _nfts;
  }

}


/**
 * Upgradeable implementation.
 */
contract BubbleCommunityImplementation is BubbleCommunityStorage {

  /**
   * @dev maximum number of members allowed in the community
   */
  uint public constant MAX_MEMBERS = 150;

  /**
   * @dev community admin role gives rights to register, deregister and ban arbitrary users
   */
  bytes32 public constant MEMBER_ADMIN_ROLE = keccak256("MEMBER_ADMIN_ROLE");

  /**
   * @dev nft admin role gives rights to register and deregister NFT rounds
   */
  bytes32 public constant NFT_ADMIN_ROLE = keccak256("NFT_ADMIN_ROLE");

  /**
   * @dev verify eternal storage and initialise roles for the owner
   */
  function initialise() external onlyOwner onlyProxy {
    _verifyEternalStorage(_endOfStorage);
    require(!initialised, "already initialised");
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _grantRole(MEMBER_ADMIN_ROLE, msg.sender);
    _grantRole(NFT_ADMIN_ROLE, msg.sender);
    initialised = true;
  }
  
  /**
   * @dev register yourself as member of the community
   */
  function registerAsMember(bytes32[] memory socials) external {
    _registerMember(msg.sender, socials);
  }

  /**
   * @dev registers the given user as a member of the community
   */
  function registerMember(address member, bytes32[] memory socials) external onlyRole(MEMBER_ADMIN_ROLE) {
    _registerMember(member, socials);
  }

  /**
   * @dev update your social usernames
   */
  function updateSocials(bytes32[] memory oldSocials, bytes32[] memory newSocials) external {
    _deregisterMember(msg.sender, oldSocials);
    _registerMember(msg.sender, newSocials);
  }

  /**
   * @dev update social usernames for specific member
   */
  function updateSocials(address member, bytes32[] memory oldSocials, bytes32[] memory newSocials) external onlyRole(MEMBER_ADMIN_ROLE) {
    _deregisterMemberSocials(member, oldSocials);
    _registerMemberSocials(member, newSocials);
  }

  /**
   * @dev deregister yourself from the community
   */
  function deregisterAsMember(bytes32[] memory socials) external {
    _deregisterMember(msg.sender, socials);
  }

  /**
   * @dev deregisters the given user from the community
   */
  function deregisterMember(address member, bytes32[] memory socials) external onlyRole(MEMBER_ADMIN_ROLE) {
    _deregisterMember(member, socials);
  }

  /**
   * @dev deregisters the given member and bans their socials.
   * Note, there is no point banning the member address since it is trivial to create a new one.
   */
  function banMember(address member, bytes32[] memory socials) external onlyRole(MEMBER_ADMIN_ROLE) {
    for (uint i=0; i<socials.length; i++) {
      bytes32 usernameHash = socials[i];
      require(_socials[usernameHash] == member, 'username not owned by member');
      _socials[socials[i]] = address(1);
    }
    _deregisterMember(member, new bytes32[](0));
  }

  /**
   * @dev bans the given social usernames from the community. Usernames must not be registered.
   * If banning a specific member's usernames use `banMember`. If banned member has already
   * deregistered themselves use `updateSocials`.
   */
  function banSocials(bytes32[] memory socials) external onlyRole(MEMBER_ADMIN_ROLE) {
    _registerMemberSocials(address(1), socials);
  }

  /**
   * @dev unbans the given social usernames. Usernames must be banned.
   */
  function unbanSocials(bytes32[] memory socials) external onlyRole(MEMBER_ADMIN_ROLE) {
    _deregisterMemberSocials(address(1), socials);
  }

  /**
   * @dev registers a new NFT to this community
   */
  function registerNFT(address nftContract) external onlyRole(NFT_ADMIN_ROLE) {
    require (!hasNFT(nftContract), 'already registered');
    _nfts.push(nftContract);
  }

  /**
   * @dev returns `true` if the given contract address is a registered NFT
   */
  function hasNFT(address nftContract) public view returns (bool) {
    for (uint i=0; i<_nfts.length; i++) {
      if (_nfts[i] == nftContract) return true;
    }
    return false;
  }

  /**
   * @dev deregisters an NFT from this community
   */
  function deregisterNFT(address nftContract) external onlyRole(NFT_ADMIN_ROLE) {
    uint len = _nfts.length;
    require (len > 0, 'nft list empty');
    for (uint i=0; i<len; i++) {
      if (_nfts[i] == nftContract) {
        _nfts[i] = _nfts[len-1];
        _nfts.pop();
        return;
      }
    }
    revert('nft not registered');
  }


  //
  // Private methods
  //

  
  /**
   * @dev registers the given user 
   */
  function _registerMember(address member, bytes32[] memory socials) private {
    require (!_members[member], 'already a member');
    require (_memberCount < MAX_MEMBERS, 'membership full');
    _registerMemberSocials(member, socials);
    _members[member] = true;
    _memberCount++;
  }

  /**
   * @dev registers the given usernames to the given member. Reverts if any username is
   * already registered 
   */
  function _registerMemberSocials(address member, bytes32[] memory socials) private {
    for (uint i=0; i<socials.length; i++) {
      bytes32 usernameHash = socials[i];
      require (_socials[usernameHash] != address(1), 'username banned');
      require (_socials[usernameHash] == address(0), 'username already registered');
      _socials[usernameHash] = member;
    }
  }

  /**
   * @dev deregisters the given member and socials 
   */
  function _deregisterMember(address member, bytes32[] memory socials) private {
    require (_members[member], 'not a member');
    _deregisterMemberSocials(member, socials);
    _members[member] = false;
    if (_memberCount > 0) _memberCount--;  // It's possible 
  }

  /**
   * @dev deregisters the given socials. Reverts if any username is not owned by the member.
   */
  function _deregisterMemberSocials(address member, bytes32[] memory socials) private {
    for (uint i=0; i<socials.length; i++) {
      bytes32 usernameHash = socials[i];
      require(_socials[usernameHash] == member, 'username not owned by member');
      _socials[usernameHash] = address(0);
    }
  }

}