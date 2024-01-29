// SPDX-License-Identifier: GPL-3.0
        
pragma solidity 0.8.24;

import "./BubbleCommunity_test_common.sol";
import "../AccessControlBits.sol";

contract testSuite is testSuite_template {

    address nonMember = address(1);
    address registeredNft = address(100);
    address nonRegisteredNft = address(101);
    uint256 nonAddressableFile = 2**160;

    function beforeAll() public {
        init();
        // Register members & NFTs
        member1.registerAsMember(new bytes32[](0));
        member2.registerAsMember(new bytes32[](0));
        community.registerNFT(registeredNft);
        // Set roles
        community.grantRole(community.MEMBER_ADMIN_ROLE(), address(memberAdmin));
        community.grantRole(community.NFT_ADMIN_ROLE(), address(nftAdmin));
    }


    // Root Dir

    function checkOwnerCanCreateTheBubble() public {
        Assert.equal(community.getAccessPermissions(address(this), 0), RWA_BITS, 'owner cannot create the bubble');
    }

    function checkMemberCannotAccessRoot() public {
        Assert.equal(community.getAccessPermissions(address(member1), 0), NO_PERMISSIONS, 'only owner and member admins can read the root');
    }

    function checkNonMemberCannotAccessRoot() public {
        Assert.equal(community.getAccessPermissions(nonMember, 0), NO_PERMISSIONS, 'only owner and member admins can read the root');
    }

    function checkNftAdminCannotAccessRoot() public {
        Assert.equal(community.getAccessPermissions(address(nftAdmin), 0), NO_PERMISSIONS, 'only owner and member admins can read the root');
    }

    function checkMemberAdminCanReadRoot() public {
        Assert.equal(community.getAccessPermissions(address(memberAdmin), 0), READ_BIT, 'member admin should be able to read the root');
    }


    // Member File

    function checkMemberCanWriteToTheirFile() public {
        Assert.equal(community.getAccessPermissions(address(member1), uint256(uint160(address(member1)))), RWA_BITS, 'member cannot write to their file');
    }

    function checkNonMemberCannotAccessAMembersFile() public {
        Assert.equal(community.getAccessPermissions(nonMember, uint256(uint160(address(member1)))), NO_PERMISSIONS, 'non-member should not have access to their file');
    }

    function checkMemberCannotAccessAnotherMembersFile() public {
        Assert.equal(community.getAccessPermissions(address(member2), uint256(uint160(address(member1)))), NO_PERMISSIONS, 'only the member should be able to write to their file');
    }

    function checkMemberAdminCanReadAndOnlyReadAMembersFile() public {
        Assert.equal(community.getAccessPermissions(address(memberAdmin), uint256(uint160(address(member1)))), READ_BIT, 'member admin should be able to read members file');
    }

    function checkNftAdminCannotAccessAMembersFile() public {
        Assert.equal(community.getAccessPermissions(address(nftAdmin), uint256(uint160(address(member1)))), NO_PERMISSIONS, 'member admin should be able to read members file');
    }

    function checkNonMemberCannotAccessTheirFile() public {
        Assert.equal(community.getAccessPermissions(nonMember, uint256(uint160(nonMember))), NO_PERMISSIONS, 'non-member should not have access to their file');
    }


    // NFT Dir

    function checkNftAdminCanWriteToRegisteredNftDir() public {
        Assert.equal(community.getAccessPermissions(address(nftAdmin), uint256(uint160(registeredNft))), DRWA_BITS, 'nft admin should be able to read and write to dir');
    }

    function checkNftAdminCanWriteToNonRegisteredNftDir() public {
        Assert.equal(community.getAccessPermissions(address(nftAdmin), uint256(uint160(nonRegisteredNft))), DRWA_BITS, 'nft admin should be able to read and write to dir');
    }

    function checkNonNftAdminsCannotAccessNonRegisteredNftDir() public {
        Assert.equal(community.getAccessPermissions(nonMember, uint256(uint160(nonRegisteredNft))), NO_PERMISSIONS, 'non-registered member should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(member1), uint256(uint160(nonRegisteredNft))), NO_PERMISSIONS, 'member should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(memberAdmin), uint256(uint160(nonRegisteredNft))), NO_PERMISSIONS, 'member admin should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(nonRegisteredNft), uint256(uint160(nonRegisteredNft))), NO_PERMISSIONS, 'nft itself should not be able to access dir');
    }

    function checkRegisteredNftDirIsPubliclyReadable() public {
        Assert.equal(community.getAccessPermissions(nonMember, uint256(uint160(registeredNft))), READ_BIT, 'non-registered member should be able to read dir');
        Assert.equal(community.getAccessPermissions(address(member1), uint256(uint160(registeredNft))), READ_BIT, 'member should be able to read dir');
        Assert.equal(community.getAccessPermissions(address(memberAdmin), uint256(uint160(registeredNft))), READ_BIT, 'member admin should be able to read dir');
        Assert.equal(community.getAccessPermissions(address(registeredNft), uint256(uint160(registeredNft))), READ_BIT, 'nft itself should be able to read dir');
    }


    // Other files

    function checkNooneCanAccessNonAddressableFile() public {
        Assert.equal(community.getAccessPermissions(nonMember, nonAddressableFile), NO_PERMISSIONS, 'non-registered member should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(member1), nonAddressableFile), NO_PERMISSIONS, 'member should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(memberAdmin), nonAddressableFile), NO_PERMISSIONS, 'member admin should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(nftAdmin), nonAddressableFile), NO_PERMISSIONS, 'nft admin should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(this), nonAddressableFile), NO_PERMISSIONS, 'owner should not be able to access dir');
    }


}
