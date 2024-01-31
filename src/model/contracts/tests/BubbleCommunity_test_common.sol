// SPDX-License-Identifier: GPL-3.0
        
pragma solidity 0.8.24;

import "remix_tests.sol"; 
import {BubbleCommunity, BubbleCommunityImplementation} from "../BubbleCommunity.sol";
import {CommunityUser} from "./CommunityUser.sol";

uint constant TEST_MAX_SOCIALS = 5;

contract testSuite_template {

    address owner = address(this);
    CommunityUser member1;
    CommunityUser member2;
    CommunityUser memberAdmin;
    CommunityUser nftAdmin;

    BubbleCommunity communityStorage;
    BubbleCommunityImplementation implementation;
    BubbleCommunityImplementation community;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32[TEST_MAX_SOCIALS] internal NULL_SOCIALS;

    function init() internal {
        // Construct community contract
        communityStorage = new BubbleCommunity();
        implementation = new BubbleCommunityImplementation();
        communityStorage.upgradeImplementation(address(implementation));
        community = BubbleCommunityImplementation(address(communityStorage));
        community.initialise();
        Assert.equal(community.initialised(), true, "community should be initialised after calling initialise");
        // Construct test members and admins
        member1 = new CommunityUser(community);
        member2 = new CommunityUser(community);
        memberAdmin = new CommunityUser(community);
        nftAdmin = new CommunityUser(community);
    }

    function assertAccessControlUnauthorizedAccountError(bytes memory reason, bytes32 role) internal {
        bytes4 expectedSelector = bytes4(keccak256(bytes("AccessControlUnauthorizedAccount(address,bytes32)")));
        bytes4 receivedSelector = bytes4(reason);
        Assert.equal(receivedSelector, expectedSelector, "unexpected error type");
        bytes32 receivedRole;
        assembly {
            receivedRole := mload(add(reason, 68))
        }
        Assert.equal(receivedRole, role, "unexpected error type");
    }

    function assertOwnableUnauthorizedAccountError(bytes memory reason) internal {
        bytes4 expectedSelector = bytes4(keccak256(bytes("OwnableUnauthorizedAccount(address)")));
        bytes4 receivedSelector = bytes4(reason);
        Assert.equal(receivedSelector, expectedSelector, "unexpected error type");
    }

    function _dynToFixed(bytes32[] memory dyn) internal pure returns (bytes32[TEST_MAX_SOCIALS] memory fixedArray) {
        require(dyn.length <= TEST_MAX_SOCIALS, "Input array too large");
        for (uint i=0; i<dyn.length; i++) {
            fixedArray[i] = dyn[i];
        }
        return fixedArray;
    }

}
