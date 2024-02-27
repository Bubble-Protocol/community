// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/proxy/Proxy.sol";
import "IMemberRegistry.sol";
import "../EternalStorage.sol";
import "AccessControlledStorage.sol";
import "AccessControlBits.sol";


uint constant NUM_SOCIALS = 3; // Current fixed number of socials
uint constant MAX_SOCIALS = 5; // Max limit, allowing for future expansion
address constant BANNED_FLAG = address(1);

/**
 * The registry data definition. Non-upgradeable eternal storage.
 */
abstract contract BubbleCommunityStorage is EternalStorage, AccessControl {

  uint internal _memberCount;
  mapping (address => address) internal _members;
  mapping (address => bytes32[MAX_SOCIALS]) internal _memberSocials;
  mapping (bytes32 => address) internal _socials;
  address[] internal _nfts;

  bytes32 internal _endOfStorage = END_OF_STORAGE;

}


/**
 * The community storage contract. The eternal data plus getter functions. Non-upgradeable.
 */
contract BubbleCommunity is BubbleCommunityStorage, Proxy {

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

}



/*
 * Implementation dependent bubble directories
 */

uint constant PUBLIC_DIR = 0x8000000000000000000000000000000000000000000000000000000000000001;        // Directory for public files like NFT images
uint constant MEMBER_DIR = 0x8000000000000000000000000000000000000000000000000000000000000002;        // Directory restricted to members only
uint constant MEMBER_ADMIN_DIR = 0x8000000000000000000000000000000000000000000000000000000000000003;  // Directory restricted to member admins only


/**
 * Upgradeable implementation.
 */
contract BubbleCommunityImplementation is BubbleCommunityStorage, IMemberRegistry, AccessControlledStorage {

  /**
   * @dev maximum number of members allowed in the community
   */
  uint public constant MAX_MEMBERS = 1200;

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
   * @dev returns a list of all the registered nft contracts
   */
  function getNFTs() external view returns (address[] memory) {
    return _nfts;
  }

  /**
   * @dev register yourself as member of the community
   */
  function registerAsMember(address login, bytes32[MAX_SOCIALS] memory socials) external {
    _registerMember(msg.sender, login, socials);
  }

  /**
   * @dev registers the given user as a member of the community
   */
  function registerMember(address member, address login, bytes32[MAX_SOCIALS] memory socials) external onlyRole(MEMBER_ADMIN_ROLE) {
    _registerMember(member, login, socials);
  }

  /**
   * @dev update your social usernames
   */
  function updateSocials(bytes32[MAX_SOCIALS] memory socials) external {
    _updateSocials(msg.sender, socials);
  }

  /**
   * @dev update social usernames for specific member
   */
  function updateSocials(address member, bytes32[MAX_SOCIALS] memory socials) external onlyRole(MEMBER_ADMIN_ROLE) {
    _updateSocials(member, socials);
  }

  /**
   * @dev deregister yourself from the community
   */
  function deregisterAsMember() external {
    _deregisterMember(msg.sender);
  }

  /**
   * @dev deregisters the given user from the community
   */
  function deregisterMember(address member) external onlyRole(MEMBER_ADMIN_ROLE) {
    _deregisterMember(member);
  }

  /**
   * @dev returns `true` if the given address is a registered member of the community
   */
  function isMember(address member) public view returns (bool) {
    return _members[member] != address(0) && _members[member] != BANNED_FLAG;
  }

  /**
   * @dev returns `true` if the given address is a registered member of the community
   */
  function isLoginFor(address member, address login) public view returns (bool) {
    return _members[member] == login;
  }

  /**
   * @dev bans the given member and their socials.
   */
  function banMember(address member) external onlyRole(MEMBER_ADMIN_ROLE) {
    _banMember(member);
  }

  /**
   * @dev bans the given social usernames from the community. Usernames must not be registered.
   * If banning a specific member's usernames use `banMember`.
   */
  function banSocials(bytes32[] memory socials) external onlyRole(MEMBER_ADMIN_ROLE) {
    for (uint i=0; i<socials.length; i++) _banSocial(socials[i]);
  }

  /**
   * @dev unbans the given member allowing them to re-register.
   */
  function unbanMember(address member) external onlyRole(MEMBER_ADMIN_ROLE) {
    _unbanMember(member);
  }

  /**
   * @dev unbans the given social usernames. Usernames must be banned.
   */
  function unbanSocials(bytes32[] memory socials) external onlyRole(MEMBER_ADMIN_ROLE) {
    for (uint i=0; i<socials.length; i++) _unbanSocial(socials[i]);
  }

  /**
   * @dev returns `true` if the given address is banned from the community
   */
  function isBanned(address member) public view returns (bool) {
    return _members[member] == BANNED_FLAG;
  }

  /**
   * @dev returns `true` if the given social is banned from the community
   */
  function isBanned(bytes32 usernameHash) public view returns (bool) {
    return _socials[usernameHash] == BANNED_FLAG;
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

  /**
   * @dev bubble permissions
   */
  function getAccessPermissions( address user, uint256 contentId ) external view override returns (uint256) {

    // Only the owner has permission to create the bubble. Member admins can read the root
    if (contentId == 0) return 
      hasRole(DEFAULT_ADMIN_ROLE, user) ? DRWA_BITS 
      : hasRole(MEMBER_ADMIN_ROLE, user) ? DIRECTORY_BIT | READ_BIT
      : NO_PERMISSIONS;

    // Public dir is readable by the public and writable by all admins
    if (contentId == PUBLIC_DIR) return 
      hasRole(MEMBER_ADMIN_ROLE, user) || hasRole(NFT_ADMIN_ROLE, user) ? DRWA_BITS 
      : DIRECTORY_BIT | READ_BIT;

    // Member dir is readable by members and writable by member admins
    bool member = isMember(user);
    if (contentId == MEMBER_DIR) return 
      hasRole(MEMBER_ADMIN_ROLE, user) ? DRWA_BITS 
      : member ? DIRECTORY_BIT | READ_BIT
      : NO_PERMISSIONS;

    // Member admins have rwa access to the admin directory
    if (contentId == MEMBER_ADMIN_DIR && hasRole(MEMBER_ADMIN_ROLE, user)) return DRWA_BITS;

    // Only other content within address range is applicable to this bubble
    if (contentId < 2**160) {
      address contentAddr = address(uint160(contentId));
      if (isMember(contentAddr)) {
        if (member && contentAddr == user) return RWA_BITS;          // Members have rwa access to their own file
        if (isLoginFor(contentAddr, user)) return RWA_BITS;          // Member login addresses have rwa access to their own file
        if (hasRole(MEMBER_ADMIN_ROLE, user)) return READ_BIT;       // Member admins have read access to members' files
      }
      else if (hasRole(MEMBER_ADMIN_ROLE, user)) return WRITE_BIT;   // Member admins have access to delete deregistered and banned members' files
    }

    return NO_PERMISSIONS;
  }


  //
  // Private methods
  //

  
  /**
   * @dev registers the given user 
   */
  function _registerMember(address member, address login, bytes32[MAX_SOCIALS] memory socials) private {
    require (_members[member] != BANNED_FLAG, 'user banned');
    require (_members[member] == address(0), 'already a member');
    require (_memberCount < MAX_MEMBERS, 'membership full');
    for (uint i=0; i<NUM_SOCIALS; i++) {
      bytes32 usernameHash = socials[i];
      require (usernameHash != 0, 'username is null');
      require (_socials[usernameHash] != address(1), 'username banned');
      require (_socials[usernameHash] == address(0), 'username already registered');
      _socials[usernameHash] = member;
    }
    _memberSocials[member] = socials;
    _members[member] = login;
    _memberCount++;
  }

  /**
   * @dev deregisters the given member and socials 
   */
  function _deregisterMember(address member) private {
    require (_members[member] != BANNED_FLAG, 'user banned');
    require (isMember(member), 'not a member');
    bytes32[MAX_SOCIALS] memory socials = _memberSocials[member];
    for (uint i=0; i<MAX_SOCIALS; i++) delete _socials[socials[i]];
    delete _memberSocials[member];
    delete _members[member];
    if (_memberCount > 0) _memberCount--;
  }

  /**
   * @dev update socials for the given user 
   */
  function _updateSocials(address member, bytes32[MAX_SOCIALS] memory newSocials) private {
    require (_members[member] != BANNED_FLAG, 'user banned');
    require (_members[member] != address(0), 'not a member');
    bytes32[MAX_SOCIALS] memory oldSocials = _memberSocials[member];
    for (uint i=0; i<MAX_SOCIALS; i++) delete _socials[oldSocials[i]];
    for (uint i=0; i<NUM_SOCIALS; i++) {
      bytes32 usernameHash = newSocials[i];
      require (_socials[usernameHash] != BANNED_FLAG, 'username banned');
      require (_socials[usernameHash] == address(0), 'username already registered');
      _socials[usernameHash] = member;
    }
    _memberSocials[member] = newSocials;
  }

  /**
   * @dev bans the member and all of their socials
   */
  function _banMember(address member) private {
    require (_members[member] != BANNED_FLAG, 'already banned');
    require (isMember(member), 'not a member');
    bytes32[MAX_SOCIALS] memory socials = _memberSocials[member];
    for (uint i=0; i<MAX_SOCIALS; i++) {
      bytes32 usernameHash = socials[i];
      if (usernameHash != 0) _socials[usernameHash] = BANNED_FLAG;
    }
    delete _memberSocials[member];
    _members[member] = BANNED_FLAG;
    if (_memberCount > 0) _memberCount--;
  }

  /**
   * @dev unbans the given member allowing them to re-register
   */
  function _unbanMember(address member) private {
    require(_members[member] == BANNED_FLAG, 'member is not banned');
    delete _members[member];
  }

  /**
   * @dev bans the given social provided it is not registered
   */
  function _banSocial(bytes32 social) private {
    require(_socials[social] == address(0), 'username is registered');
    if (social != 0) _socials[social] = BANNED_FLAG;
  }

  /**
   * @dev unbans the given social provided it is banned
   */
  function _unbanSocial(bytes32 social) private {
    require(_socials[social] == BANNED_FLAG, 'username is not banned');
    delete _socials[social];
  }

}