// SPDX-License-Identifier: GPL-3.0
        
pragma solidity 0.8.24;

import "./BubbleCommunity_test_common.sol";
import "../AccessControlBits.sol";

contract testSuite is testSuite_template {

    address nonMember = address(1);
    address registeredNft = address(100);
    address nonRegisteredNft = address(101);
    uint256 nonAddressableFile = 2**160;
    uint256 adminDir = 2**255 + 1;

    function beforeAll() public {
        init();
        // Register members & NFTs
        bytes32[] memory member1Socials = new bytes32[](3);
        member1Socials[0] = bytes32(0x0101000000000000000000000000000000000000000000000000000000000000);
        member1Socials[1] = bytes32(0x0102000000000000000000000000000000000000000000000000000000000000);
        member1Socials[2] = bytes32(0x0103000000000000000000000000000000000000000000000000000000000000);
        member1.registerAsMember(member1Socials);
        bytes32[] memory member2Socials = new bytes32[](3);
        member2Socials[0] = bytes32(0x0201000000000000000000000000000000000000000000000000000000000000);
        member2Socials[1] = bytes32(0x0202000000000000000000000000000000000000000000000000000000000000);
        member2Socials[2] = bytes32(0x0203000000000000000000000000000000000000000000000000000000000000);
        member2.registerAsMember(member2Socials);
        Assert.equal(communityStorage.getMemberCount(), 2, 'member count should be two');
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

    function checkMemberLoginCannotAccessRoot() public {
        Assert.equal(community.getAccessPermissions(member1.login(), 0), NO_PERMISSIONS, 'only owner and member admins can read the root');
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


    // Member Files

    function checkMemberCanWriteToTheirFile() public {
        Assert.equal(community.getAccessPermissions(address(member1), uint256(uint160(address(member1)))), RWA_BITS, 'member cannot write to their file');
    }

    function checkMemberLoginCanWriteToTheirFile() public {
        Assert.equal(community.getAccessPermissions(member1.login(), uint256(uint160(address(member1)))), RWA_BITS, 'member cannot write to their file');
    }

    function checkNonMemberCannotAccessAMembersFile() public {
        Assert.equal(community.getAccessPermissions(nonMember, uint256(uint160(address(member1)))), NO_PERMISSIONS, 'non-member should not have access to their file');
    }

    function checkMemberCannotAccessAnotherMembersFile() public {
        Assert.equal(community.getAccessPermissions(address(member2), uint256(uint160(address(member1)))), NO_PERMISSIONS, 'only the member should be able to write to their file');
    }

    function checkMemberLoginCannotAccessAnotherMembersFile() public {
        Assert.equal(community.getAccessPermissions(member2.login(), uint256(uint160(address(member1)))), NO_PERMISSIONS, 'only the member should be able to write to their file');
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


    // NFT Dirs

    function checkNftAdminCanWriteToRegisteredNftDir() public {
        Assert.equal(community.getAccessPermissions(address(nftAdmin), uint256(uint160(registeredNft))), DRWA_BITS, 'nft admin should be able to read and write to dir');
    }

    function checkRegisteredNftDirIsPubliclyReadable() public {
        Assert.equal(community.getAccessPermissions(nonMember, uint256(uint160(registeredNft))), READ_BIT, 'non-registered member should be able to read dir');
        Assert.equal(community.getAccessPermissions(address(member1), uint256(uint160(registeredNft))), READ_BIT, 'member should be able to read dir');
        Assert.equal(community.getAccessPermissions(member1.login(), uint256(uint160(registeredNft))), READ_BIT, 'member login should be able to read dir');
        Assert.equal(community.getAccessPermissions(address(memberAdmin), uint256(uint160(registeredNft))), READ_BIT, 'member admin should be able to read dir');
        Assert.equal(community.getAccessPermissions(address(registeredNft), uint256(uint160(registeredNft))), READ_BIT, 'nft itself should be able to read dir');
    }


    // Non-Registered Dirs

    function checkNftAdminCanReadWriteToNonRegisteredNftDir() public {
        Assert.equal(community.getAccessPermissions(address(nftAdmin), uint256(uint160(nonRegisteredNft))), DRWA_BITS, 'nft admin should be able to read and write to dir');
    }

    function checkMemberAdminCanWriteOnlyToNonRegisteredNftDir() public {
        Assert.equal(community.getAccessPermissions(address(memberAdmin), uint256(uint160(nonRegisteredNft))), WRITE_BIT, 'member admin should be able to write-only to dir');
    }

    function checkNonAdminsCannotAccessNonRegisteredNftDir() public {
        Assert.equal(community.getAccessPermissions(nonMember, uint256(uint160(nonRegisteredNft))), NO_PERMISSIONS, 'non-registered member should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(member1), uint256(uint160(nonRegisteredNft))), NO_PERMISSIONS, 'member should not be able to access dir');
        Assert.equal(community.getAccessPermissions(member1.login(), uint256(uint160(nonRegisteredNft))), NO_PERMISSIONS, 'member login should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(nonRegisteredNft), uint256(uint160(nonRegisteredNft))), NO_PERMISSIONS, 'nft itself should not be able to access dir');
    }


    // Admin Dir

    function checkMemberAdminsCanWriteToAdminDir() public {
        Assert.equal(community.getAccessPermissions(address(memberAdmin), adminDir), DRWA_BITS, 'member admin should be able to read and write to dir');
    }

    function checkNonMemberAdminsCannotAccessAdminDir() public {
        Assert.equal(community.getAccessPermissions(nonMember, adminDir), NO_PERMISSIONS, 'non-registered member should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(member1), adminDir), NO_PERMISSIONS, 'member should not be able to access dir');
        Assert.equal(community.getAccessPermissions(member1.login(), adminDir), NO_PERMISSIONS, 'member login should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(nftAdmin), adminDir), NO_PERMISSIONS, 'nft admin should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(nonMember), adminDir), NO_PERMISSIONS, 'non-member should not be able to access dir');
    }


    // Other files

    function checkNooneCanAccessNonAddressableFile() public {
        Assert.equal(community.getAccessPermissions(nonMember, nonAddressableFile), NO_PERMISSIONS, 'non-registered member should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(member1), nonAddressableFile), NO_PERMISSIONS, 'member should not be able to access dir');
        Assert.equal(community.getAccessPermissions(member1.login(), nonAddressableFile), NO_PERMISSIONS, 'member login should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(memberAdmin), nonAddressableFile), NO_PERMISSIONS, 'member admin should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(nftAdmin), nonAddressableFile), NO_PERMISSIONS, 'nft admin should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(this), nonAddressableFile), NO_PERMISSIONS, 'owner should not be able to access dir');
    }

    //TODO check can delete deregistered member's file

}
