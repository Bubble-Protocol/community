// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/access/Ownable.sol";
import "IMemberRegistry.sol";

/**
 * Structure for batch minting
 */
struct Mint {
  address to;
  uint256 value;
}


/**
 * Bubble Protocol pre-governance designed to capture rewards for community members during promotions and referral schemes.
 * Tokens are non-transferable, designed instead to be converted to governance tokens or other rewards at a later date.
 *
 * TODO: Check user is a member of the community before minting
 * TODO: Add claim flag?
 */
contract BubblePreGovernanceToken is ERC20, Ownable {

    uint256 private _nextTokenId;
    bool private _closed = false;
    IMemberRegistry private _memberRegistry;

    constructor(string memory name, string memory ticker, IMemberRegistry memberRegistry) ERC20(name, ticker) Ownable(msg.sender) {
      _memberRegistry = memberRegistry;
    }

    /**
     * @dev mint tokens for a community member. Address must be registered with the member registry
     */
    function mint(address to, uint256 value) public onlyOwner
    {
      require(!_closed, 'round is closed');
      require(_memberRegistry.isMember(to), 'not a community member');
      _mint(to, value);
    }

    /**
     * @dev mint a batch of tokens for different members. All addresses must be registered 
     * to the member registry.
     */
    function mintBatch(Mint[] memory batch) public onlyOwner
    {
      require(!_closed, 'round is closed');
      for (uint i=0; i<batch.length; i++) {
        Mint memory item = batch[i];
        address to = item.to;
        require(_memberRegistry.isMember(to), 'not a community member');
        _mint(item.to, item.value);
      }
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
     * @dev tokens are non-transferable
     */
    function transfer(address /*to*/, uint256 /*value*/) public pure override returns (bool) {
      revert('tokens are non-transferable');
    }

    /**
     * @dev tokens are non-transferable
     */
    function transferFrom(address /*from*/, address /*to*/, uint256 /*value*/) public pure override returns (bool) {
      revert('tokens are non-transferable');
    }

    /**
     * @dev tokens are non-transferable
     */
    function approve(address /*to*/, uint256 /*value*/) public pure override returns (bool) {
      revert('tokens are non-transferable');
    }

    /**
     * @dev tokens are non-transferable
     */
    function allowance(address /*owner*/, address /*spender*/) public view override returns (uint256) {
      revert('tokens are non-transferable');
    }

}