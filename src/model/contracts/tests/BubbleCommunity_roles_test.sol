// SPDX-License-Identifier: GPL-3.0
        
pragma solidity 0.8.24;

import "./BubbleCommunity_test_common.sol";

contract testSuite is testSuite_template {

    event Log(string message);
    event LogBytes(bytes data);

    function beforeAll() public {
        init();
    }

    function tryToCallInitialiseWithoutAdminRole() public {
        try member1.initialise(Mintable(address(communityToken))) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "permission denied", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToCallRegisterMemberWithoutMemberAdminRole() public {
        try member1.registerMember(address(member1), new bytes32[](0)) {
            Assert.ok(false, "method should revert");
        } catch (bytes memory reason) {
            assertAccessControlUnauthorizedAccountError(reason, community.MEMBER_ADMIN_ROLE());
        }
    }

    function tryToCallDeregisterMemberWithoutMemberAdminRole() public {
        try member1.deregisterMember(address(member1)) {
            Assert.ok(false, "method should revert");
        } catch (bytes memory reason) {
            assertAccessControlUnauthorizedAccountError(reason, community.MEMBER_ADMIN_ROLE());
        }
    }

    function tryToCallUpdateSocialsWithoutMemberAdminRole() public {
        try member1.updateSocials(address(member1), new bytes32[](0)) {
            Assert.ok(false, "method should revert");
        } catch (bytes memory reason) {
            assertAccessControlUnauthorizedAccountError(reason, community.MEMBER_ADMIN_ROLE());
        }
    }

    function tryToCallBanMemberWithoutMemberAdminRole() public {
        try member1.banMember(address(member1)) {
            Assert.ok(false, "method should revert");
        } catch (bytes memory reason) {
            assertAccessControlUnauthorizedAccountError(reason, community.MEMBER_ADMIN_ROLE());
        }
    }

    function tryToCallBanSocialsWithoutMemberAdminRole() public {
        try member1.banSocials(new bytes32[](0)) {
            Assert.ok(false, "method should revert");
        } catch (bytes memory reason) {
            assertAccessControlUnauthorizedAccountError(reason, community.MEMBER_ADMIN_ROLE());
        }
    }

    function tryToCallUnbanMembersWithoutMemberAdminRole() public {
        try member1.unbanMember(address(member1)) {
            Assert.ok(false, "method should revert");
        } catch (bytes memory reason) {
            assertAccessControlUnauthorizedAccountError(reason, community.MEMBER_ADMIN_ROLE());
        }
    }

    function tryToCallUnbanSocialsWithoutMemberAdminRole() public {
        try member1.unbanSocials(new bytes32[](0)) {
            Assert.ok(false, "method should revert");
        } catch (bytes memory reason) {
            assertAccessControlUnauthorizedAccountError(reason, community.MEMBER_ADMIN_ROLE());
        }
    }

    function tryToCallRegisterNFTWithoutMemberAdminRole() public {
        try member1.registerNFT(address(0)) {
            Assert.ok(false, "method should revert");
        } catch (bytes memory reason) {
            assertAccessControlUnauthorizedAccountError(reason, community.NFT_ADMIN_ROLE());
        }
    }

    function tryToCallDeregisterNFTWithoutMemberAdminRole() public {
        try member1.deregisterNFT(address(0)) {
            Assert.ok(false, "method should revert");
        } catch (bytes memory reason) {
            assertAccessControlUnauthorizedAccountError(reason, community.NFT_ADMIN_ROLE());
        }
    }

}
