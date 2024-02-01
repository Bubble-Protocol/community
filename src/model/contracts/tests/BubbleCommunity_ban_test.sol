// SPDX-License-Identifier: GPL-3.0
        
pragma solidity 0.8.24;

import "./BubbleCommunity_test_common.sol";

contract testSuite is testSuite_template {

    bytes32[TEST_MAX_SOCIALS] member1Socials;
    bytes32[TEST_MAX_SOCIALS] member2Socials;
    bytes32[] member1Socials_dynamic = new bytes32[](3);

    function beforeAll() public {
        init();
        member1Socials[0] = bytes32(0x0101000000000000000000000000000000000000000000000000000000000000);
        member1Socials[1] = bytes32(0x0102000000000000000000000000000000000000000000000000000000000000);
        member1Socials[2] = bytes32(0x0103000000000000000000000000000000000000000000000000000000000000);
        community.registerMember(address(member1), member1.login(), member1Socials);
        member2Socials[0] = bytes32(0x0201000000000000000000000000000000000000000000000000000000000000);
        member2Socials[1] = bytes32(0x0202000000000000000000000000000000000000000000000000000000000000);
        member2Socials[2] = bytes32(0x0203000000000000000000000000000000000000000000000000000000000000);
        community.registerMember(address(member2), member2.login(), member2Socials);
        Assert.equal(community.getMemberCount(), 2, 'member count should be two');
        member1Socials_dynamic[0] = member1Socials[0];
        member1Socials_dynamic[1] = member1Socials[1];
        member1Socials_dynamic[2] = member1Socials[2];
    }

    function banMember1() public {
        uint prevMemberCount = community.getMemberCount();
        community.banMember(address(member1));
        Assert.equal(community.getMemberCount(), prevMemberCount-1, 'member count should have decreased by one');
        Assert.equal(community.isMember(address(member1)), false, 'isMember should be false after banning');
        Assert.equal(community.isBanned(address(member1)), true, 'member should be banned');
        Assert.equal(community.isBanned(member1Socials[0]), true, 'social 0 should be banned');
        Assert.equal(community.isBanned(member1Socials[1]), true, 'social 1 should be banned');
        Assert.equal(community.isBanned(member1Socials[2]), true, 'social 2 should be banned');
        Assert.equal(community.getUserAddress(member1Socials[0]), address(1), 'social 0 owner should be one after banning');
        Assert.equal(community.getUserAddress(member1Socials[1]), address(1), 'social 1 owner should be one after banning');
        Assert.equal(community.getUserAddress(member1Socials[2]), address(1), 'social 2 owner should be one after banning');
    }

    function tryToBanAgain() public {
        Assert.equal(community.isMember(address(member1)), false, 'member must be unregistered before test');
        try community.banMember(address(member1)) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "already banned", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToReregisterAsMember() public {
        Assert.equal(community.isMember(address(member1)), false, 'member must be unregistered before test');
        try member1.registerAsMember(member1Socials_dynamic) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "user banned", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToReregisterAsAdmin() public {
        Assert.equal(community.isMember(address(member1)), false, 'member must be unregistered before test');
        try community.registerMember(address(member1), member1.login(), member1Socials) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "user banned", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToDeregisterAsMember() public {
        Assert.equal(community.isMember(address(member1)), false, 'member must be unregistered before test');
        try member1.deregisterAsMember() {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "user banned", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToDeregisterAsAdmin() public {
        Assert.equal(community.isMember(address(member1)), false, 'member must be unregistered before test');
        try community.deregisterMember(address(member1)) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "user banned", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToUpdateSocialsAsMember() public {
        Assert.equal(community.isMember(address(member1)), false, 'member must be unregistered before test');
        try member1.updateSocials(member1Socials_dynamic) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "user banned", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToUpdateSocialsAsAdmin() public {
        Assert.equal(community.isMember(address(member1)), false, 'member must be unregistered before test');
        try community.updateSocials(address(member1), member1Socials) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "user banned", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function unbanMember1() public {
        Assert.equal(community.isBanned(address(member1)), true, 'isBanned should be true before test');
        Assert.equal(community.getUserAddress(member1Socials[0]), address(1), 'social 0 owner must be banned before test');
        uint prevMemberCount = community.getMemberCount();
        community.unbanMember(address(member1));
        Assert.equal(community.isBanned(address(member1)), false, 'isBanned should be false after unbanning');
        Assert.equal(community.getMemberCount(), prevMemberCount, 'member count should be unchanged after unbanning');
        Assert.equal(community.isBanned(member1Socials[0]), true, 'social 0 should still be banned');
        Assert.equal(community.isBanned(member1Socials[1]), true, 'social 1 should still be banned');
        Assert.equal(community.isBanned(member1Socials[2]), true, 'social 2 should still be banned');
        Assert.equal(community.getUserAddress(member1Socials[0]), address(1), 'social 0 owner should still be banned');
        Assert.equal(community.getUserAddress(member1Socials[1]), address(1), 'social 1 owner should still be banned');
        Assert.equal(community.getUserAddress(member1Socials[2]), address(1), 'social 2 owner should still be banned');
    }

    function tryToReregisterSocialAsMember() public {
        Assert.equal(community.isMember(address(member1)), false, 'member must be unregistered before test');
        try member1.registerAsMember(member1Socials_dynamic) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "username banned", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToReregisterSocialAsAdmin() public {
        Assert.equal(community.isMember(address(member1)), false, 'member must be unregistered before test');
        try community.registerMember(address(member1), member1.login(), member1Socials) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "username banned", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function unbanMember1Socials() public {
        Assert.equal(community.getUserAddress(member1Socials[0]), address(1), 'social 0 owner must be banned before test');
        uint prevMemberCount = community.getMemberCount();
        community.unbanSocials(member1Socials_dynamic);
        Assert.equal(community.getMemberCount(), prevMemberCount, 'member count should be unchanged after unbanning');
        Assert.equal(community.getUserAddress(member1Socials[0]), address(0), 'social 0 owner should be zero after unbanning');
        Assert.equal(community.getUserAddress(member1Socials[1]), address(0), 'social 1 owner should be zero after unbanning');
        Assert.equal(community.getUserAddress(member1Socials[2]), address(0), 'social 2 owner should be zero after unbanning');
    }

    function tryToBanUnregisteredMember() public {
        Assert.equal(community.isMember(address(member1)), false, 'member must be unregistered before test');
        try community.banMember(address(member1)) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "not a member", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function ensureMember1CanReregisterAfterUnbanning() public {
        Assert.equal(community.isMember(address(member1)), false, 'isMember should be false before registering');
        uint prevMemberCount = community.getMemberCount();
        member1.registerAsMember(member1Socials_dynamic);
        Assert.equal(community.getMemberCount(), prevMemberCount+1, 'member count should have increased by one');
        Assert.equal(community.isMember(address(member1)), true, 'isMember should be true after registering');
        Assert.equal(community.getUserAddress(member1Socials[0]), address(member1), 'social 0 owner should be member after registering');
        Assert.equal(community.getUserAddress(member1Socials[1]), address(member1), 'social 1 owner should be member after registering');
        Assert.equal(community.getUserAddress(member1Socials[2]), address(member1), 'social 2 owner should be member after registering');
    }

}
