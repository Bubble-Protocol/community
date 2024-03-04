// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

abstract contract Mintable {

    function mint(address to, uint256 value) public virtual;

    function balanceOf(address account) public view virtual returns (uint256);
    
}