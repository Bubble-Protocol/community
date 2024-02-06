// SPDX-License-Identifier: GPL-3.0
        
pragma solidity 0.8.24;

import "./BubbleCommunity_test_common.sol";
import "../AccessControlBits.sol";

uint constant DR_BITS = DIRECTORY_BIT | READ_BIT;

contract testSuite is testSuite_template {

    address nonMember = address(1000);
    address bannedMember = address(1001);
    address bannedMemberLogin = address(1002);
    address unregisteredMember = address(1003);
    uint256 nonAddressableFile = 2**160;
    uint256 PUBLIC_DIR = 2**255 + 1;
    uint256 MEMBER_DIR = 2**255 + 2;
    uint256 MEMBER_ADMIN_DIR = 2**255 + 3;

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
        bytes32[5] memory bannedMemberSocials;
        bannedMemberSocials[0] = bytes32(0x0301000000000000000000000000000000000000000000000000000000000000);
        bannedMemberSocials[1] = bytes32(0x0302000000000000000000000000000000000000000000000000000000000000);
        bannedMemberSocials[2] = bytes32(0x0303000000000000000000000000000000000000000000000000000000000000);
        community.registerMember(bannedMember, bannedMemberLogin, bannedMemberSocials);
        community.banMember(bannedMember);
        Assert.equal(community.isBanned(bannedMember), true, 'bannedMember should be banned');
        Assert.equal(community.getMemberCount(), 2, 'member count should be two');
        // Set roles
        community.grantRole(community.MEMBER_ADMIN_ROLE(), address(memberAdmin));
        community.grantRole(community.NFT_ADMIN_ROLE(), address(nftAdmin));
        community.revokeRole(community.MEMBER_ADMIN_ROLE(), address(this));
        community.revokeRole(community.NFT_ADMIN_ROLE(), address(this));
    }


    // Root Dir

    function checkOwnerCanCreateTheBubble() public {
        Assert.equal(community.getAccessPermissions(address(this), 0), DRWA_BITS, 'owner cannot create the bubble');
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

    function checkBannedMemberCannotAccessRoot() public {
        Assert.equal(community.getAccessPermissions(bannedMember, 0), NO_PERMISSIONS, 'only owner and member admins can read the root');
    }

    function checkBannedMemberLoginCannotAccessRoot() public {
        Assert.equal(community.getAccessPermissions(bannedMemberLogin, 0), NO_PERMISSIONS, 'only owner and member admins can read the root');
    }

    function checkNftAdminCannotAccessRoot() public {
        Assert.equal(community.getAccessPermissions(address(nftAdmin), 0), NO_PERMISSIONS, 'only owner and member admins can read the root');
    }

    function checkMemberAdminCanReadRoot() public {
        Assert.equal(community.getAccessPermissions(address(memberAdmin), 0), DR_BITS, 'member admin should be able to read the root');
    }


    // Public Dir

    function checkPublicDirIsWritableByAllAdmins() public {
        Assert.equal(community.getAccessPermissions(address(memberAdmin), PUBLIC_DIR), DRWA_BITS, 'member admin should be able to read and write to dir');
        Assert.equal(community.getAccessPermissions(address(nftAdmin), PUBLIC_DIR), DRWA_BITS, 'nft admin should be able to read and write to dir');
    }

    function checkPublicDirIsPubliclyReadable() public {
        Assert.equal(community.getAccessPermissions(nonMember, PUBLIC_DIR), DR_BITS, 'non-registered member should be able to read dir');
        Assert.equal(community.getAccessPermissions(address(member1), PUBLIC_DIR), DR_BITS, 'member should be able to read dir');
        Assert.equal(community.getAccessPermissions(member1.login(), PUBLIC_DIR), DR_BITS, 'member login should be able to read dir');
        Assert.equal(community.getAccessPermissions(bannedMember, PUBLIC_DIR), DR_BITS, 'banned member should be able to read dir');
        Assert.equal(community.getAccessPermissions(bannedMemberLogin, PUBLIC_DIR), DR_BITS, 'banned member login should be able to read dir');
    }


    // Member Admin Dir

    function checkMemberMEMBER_ADMIN_DIRIsWritableByMemberAdmin() public {
        Assert.equal(community.getAccessPermissions(address(memberAdmin), PUBLIC_DIR), DRWA_BITS, 'member admin should be able to read and write to dir');
    }

    function checkMemberMEMBER_ADMIN_DIRIsNotReadableByNonMemberAdmins() public {
        Assert.equal(community.getAccessPermissions(nonMember, MEMBER_ADMIN_DIR), NO_PERMISSIONS, 'non-registered member should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(member1), MEMBER_ADMIN_DIR), NO_PERMISSIONS, 'member should not be able to access dir');
        Assert.equal(community.getAccessPermissions(member1.login(), MEMBER_ADMIN_DIR), NO_PERMISSIONS, 'member login should not be able to access dir');
        Assert.equal(community.getAccessPermissions(bannedMember, MEMBER_ADMIN_DIR), NO_PERMISSIONS, 'banned member should not be able to access dir');
        Assert.equal(community.getAccessPermissions(bannedMemberLogin, MEMBER_ADMIN_DIR), NO_PERMISSIONS, 'banned member login should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(nftAdmin), MEMBER_ADMIN_DIR), NO_PERMISSIONS, 'nft admin should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(nonMember), MEMBER_ADMIN_DIR), NO_PERMISSIONS, 'non-member should not be able to access dir');
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

    function checkBannedMemberCannotAccessAMembersFile() public {
        Assert.equal(community.getAccessPermissions(bannedMember, uint256(uint160(address(member1)))), NO_PERMISSIONS, 'banned-member should not have access to their file');
    }

    function checkBannedMemberLoginCannotAccessAMembersFile() public {
        Assert.equal(community.getAccessPermissions(bannedMemberLogin, uint256(uint160(address(member1)))), NO_PERMISSIONS, 'banned-member should not have access to their file');
    }

    function checkBannedMemberCannotAccessTheirOwnFile() public {
        Assert.equal(community.getAccessPermissions(bannedMember, uint256(uint160(address(bannedMember)))), NO_PERMISSIONS, 'banned-member should not have access to their own file');
    }

    function checkBannedMemberLoginCannotAccessTheirOwnFile() public {
        Assert.equal(community.getAccessPermissions(bannedMemberLogin, uint256(uint160(address(bannedMember)))), NO_PERMISSIONS, 'banned-member should not have access to their own file');
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

    function checkMemberAdminCanDeleteAndNotReadADeregisteredMembersFile() public {
        memberAdmin.deregisterMember(address(member1));
        Assert.equal(community.getAccessPermissions(address(memberAdmin), uint256(uint160(address(member1)))), WRITE_BIT, 'member admin should be able to delete members file');
    }


    // Non-Registered files

    function checkMemberAdminCanWriteOnlyToNonRegisteredMemberFile() public {
        Assert.equal(community.getAccessPermissions(address(memberAdmin), uint256(uint160(unregisteredMember))), WRITE_BIT, 'member admin should be able to write-only to dir');
    }

    function checkOnlyMemberAdminCanAccessNonRegisteredMemberFile() public {
        Assert.equal(community.getAccessPermissions(nonMember, uint256(uint160(unregisteredMember))), NO_PERMISSIONS, 'non-registered member should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(member1), uint256(uint160(unregisteredMember))), NO_PERMISSIONS, 'member should not be able to access dir');
        Assert.equal(community.getAccessPermissions(member1.login(), uint256(uint160(unregisteredMember))), NO_PERMISSIONS, 'member login should not be able to access dir');
        Assert.equal(community.getAccessPermissions(bannedMember, uint256(uint160(unregisteredMember))), NO_PERMISSIONS, 'banned member should not be able to access dir');
        Assert.equal(community.getAccessPermissions(bannedMemberLogin, uint256(uint160(unregisteredMember))), NO_PERMISSIONS, 'banned member login should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(unregisteredMember), uint256(uint160(unregisteredMember))), NO_PERMISSIONS, 'unregistered member itself should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(nftAdmin), uint256(uint160(unregisteredMember))), NO_PERMISSIONS, 'nft admin should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(this), uint256(uint160(unregisteredMember))), NO_PERMISSIONS, 'owner should not be able to access dir');
    }


    // Other files

    function checkNooneCanAccessNonAddressableFile() public {
        Assert.equal(community.getAccessPermissions(nonMember, nonAddressableFile), NO_PERMISSIONS, 'non-registered member should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(member1), nonAddressableFile), NO_PERMISSIONS, 'member should not be able to access dir');
        Assert.equal(community.getAccessPermissions(member1.login(), nonAddressableFile), NO_PERMISSIONS, 'member login should not be able to access dir');
        Assert.equal(community.getAccessPermissions(bannedMember, nonAddressableFile), NO_PERMISSIONS, 'banned member should not be able to access dir');
        Assert.equal(community.getAccessPermissions(bannedMemberLogin, nonAddressableFile), NO_PERMISSIONS, 'banned member login should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(memberAdmin), nonAddressableFile), NO_PERMISSIONS, 'member admin should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(nftAdmin), nonAddressableFile), NO_PERMISSIONS, 'nft admin should not be able to access dir');
        Assert.equal(community.getAccessPermissions(address(this), nonAddressableFile), NO_PERMISSIONS, 'owner should not be able to access dir');
    }

}
