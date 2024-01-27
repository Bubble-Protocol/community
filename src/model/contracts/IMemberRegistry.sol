// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IMemberRegistry {

  function isMember(address member) external view returns (bool);

  function getUserAddress(bytes32 usernameHash) external view returns (address);

}