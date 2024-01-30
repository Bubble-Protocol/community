// SPDX-License-Identifier: GPL-3.0
        
pragma solidity 0.8.24;

import "./BubbleCommunity_test_common.sol";

contract testSuite is testSuite_template {

    function beforeAll() public {
        init();
    }

    function registerMember1AsUser() public {
        bytes32[] memory member1Socials = new bytes32[](3);
        member1Socials[0] = bytes32(0x0101000000000000000000000000000000000000000000000000000000000000);
        member1Socials[1] = bytes32(0x0102000000000000000000000000000000000000000000000000000000000000);
        member1Socials[2] = bytes32(0x0103000000000000000000000000000000000000000000000000000000000000);
        Assert.equal(communityStorage.isMember(address(member1)), false, 'isMember should be false before registering');
        Assert.equal(communityStorage.getUserAddress(member1Socials[0]), address(0), 'social 0 owner should be zero before registering');
        Assert.equal(communityStorage.getUserAddress(member1Socials[1]), address(0), 'social 1 owner should be zero before registering');
        Assert.equal(communityStorage.getUserAddress(member1Socials[2]), address(0), 'social 2 owner should be zero before registering');
        uint prevMemberCount = communityStorage.getMemberCount();
        member1.registerAsMember(member1Socials);
        Assert.equal(communityStorage.getMemberCount(), prevMemberCount+1, 'member count should have increased by one');
        Assert.equal(communityStorage.isMember(address(member1)), true, 'isMember should be true after registering');
        Assert.equal(communityStorage.getUserAddress(member1Socials[0]), address(member1), 'social 0 owner should be member after registering');
        Assert.equal(communityStorage.getUserAddress(member1Socials[1]), address(member1), 'social 1 owner should be member after registering');
        Assert.equal(communityStorage.getUserAddress(member1Socials[2]), address(member1), 'social 2 owner should be member after registering');
    }

    function updateMember1SocialsAsUser() public {
        bytes32[] memory oldSocials = new bytes32[](3);
        oldSocials[0] = bytes32(0x0101000000000000000000000000000000000000000000000000000000000000);
        oldSocials[1] = bytes32(0x0102000000000000000000000000000000000000000000000000000000000000);
        oldSocials[2] = bytes32(0x0103000000000000000000000000000000000000000000000000000000000000);
        bytes32[] memory newSocials = new bytes32[](3);
        newSocials[0] = bytes32(0x0104000000000000000000000000000000000000000000000000000000000000);
        newSocials[1] = bytes32(0x0105000000000000000000000000000000000000000000000000000000000000);
        newSocials[2] = bytes32(0x0106000000000000000000000000000000000000000000000000000000000000);
        uint prevMemberCount = communityStorage.getMemberCount();
        member1.updateSocials(oldSocials, newSocials);
        Assert.equal(communityStorage.getMemberCount(), prevMemberCount, 'member count should be unchanged');
        Assert.equal(communityStorage.isMember(address(member1)), true, 'isMember should still be true after updating');
        Assert.equal(communityStorage.getUserAddress(oldSocials[0]), address(0), 'social 0 owner should be zero after updating');
        Assert.equal(communityStorage.getUserAddress(oldSocials[1]), address(0), 'social 1 owner should be zero after updating');
        Assert.equal(communityStorage.getUserAddress(oldSocials[2]), address(0), 'social 2 owner should be zero after updating');
        Assert.equal(communityStorage.getUserAddress(newSocials[0]), address(member1), 'social 0 owner should be member after updating');
        Assert.equal(communityStorage.getUserAddress(newSocials[1]), address(member1), 'social 1 owner should be member after updating');
        Assert.equal(communityStorage.getUserAddress(newSocials[2]), address(member1), 'social 2 owner should be member after updating');
    }

    function updateMember1SocialsAsAdmin() public {
        bytes32[] memory oldSocials = new bytes32[](3);
        oldSocials[0] = bytes32(0x0104000000000000000000000000000000000000000000000000000000000000);
        oldSocials[1] = bytes32(0x0105000000000000000000000000000000000000000000000000000000000000);
        oldSocials[2] = bytes32(0x0106000000000000000000000000000000000000000000000000000000000000);
        bytes32[] memory newSocials = new bytes32[](3);
        newSocials[0] = bytes32(0x0107000000000000000000000000000000000000000000000000000000000000);
        newSocials[1] = bytes32(0x0108000000000000000000000000000000000000000000000000000000000000);
        newSocials[2] = bytes32(0x0109000000000000000000000000000000000000000000000000000000000000);
        uint prevMemberCount = communityStorage.getMemberCount();
        community.updateSocials(address(member1), oldSocials, newSocials);
        Assert.equal(communityStorage.getMemberCount(), prevMemberCount, 'member count should be unchanged');
        Assert.equal(communityStorage.isMember(address(member1)), true, 'isMember should still be true after updating');
        Assert.equal(communityStorage.getUserAddress(oldSocials[0]), address(0), 'social 0 owner should be zero after updating');
        Assert.equal(communityStorage.getUserAddress(oldSocials[1]), address(0), 'social 1 owner should be zero after updating');
        Assert.equal(communityStorage.getUserAddress(oldSocials[2]), address(0), 'social 2 owner should be zero after updating');
        Assert.equal(communityStorage.getUserAddress(newSocials[0]), address(member1), 'social 0 owner should be member after updating');
        Assert.equal(communityStorage.getUserAddress(newSocials[1]), address(member1), 'social 1 owner should be member after updating');
        Assert.equal(communityStorage.getUserAddress(newSocials[2]), address(member1), 'social 2 owner should be member after updating');
    }

    function tryToRegisterTwice() public {
        try member1.registerAsMember(new bytes32[](0)) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "already a member", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToRegisterTwiceAsAdmin() public {
        try community.registerMember(address(member1), member1.login(), new bytes32[](0)) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "already a member", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToRegisterSocialTwice() public {
        bytes32[] memory socials = new bytes32[](1);
        socials[0] = bytes32(0x0107000000000000000000000000000000000000000000000000000000000000);
        try member2.registerAsMember(socials) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "username already registered", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToRegisterSocialTwiceAsAdmin() public {
        bytes32[] memory socials = new bytes32[](1);
        socials[0] = bytes32(0x0107000000000000000000000000000000000000000000000000000000000000);
        try community.registerMember(address(member2), member2.login(), socials) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "username already registered", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToUpdateSocialYouDoNotOwn() public {
        bytes32[] memory member2Socials = new bytes32[](1);
        member2Socials[0] = bytes32(0x0201000000000000000000000000000000000000000000000000000000000000);
        community.registerMember(address(member2), member2.login(), member2Socials);
        bytes32[] memory oldSocials = new bytes32[](3);
        oldSocials[0] = bytes32(0x0107000000000000000000000000000000000000000000000000000000000000);
        oldSocials[1] = bytes32(0x0108000000000000000000000000000000000000000000000000000000000000);
        oldSocials[2] = bytes32(0x0109000000000000000000000000000000000000000000000000000000000000);
        bytes32[] memory newSocials = new bytes32[](3);
        newSocials[0] = bytes32(0x0107000000000000000000000000000000000000000000000000000000000000);
        newSocials[1] = bytes32(0x0108000000000000000000000000000000000000000000000000000000000000);
        newSocials[2] = member2Socials[0];
        try member1.updateSocials(oldSocials, newSocials) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "username already registered", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToUseAdminToUpdateSocialMemberDoesNotOwn() public {
        bytes32[] memory oldSocials = new bytes32[](3);
        oldSocials[0] = bytes32(0x0107000000000000000000000000000000000000000000000000000000000000);
        oldSocials[1] = bytes32(0x0108000000000000000000000000000000000000000000000000000000000000);
        oldSocials[2] = bytes32(0x0109000000000000000000000000000000000000000000000000000000000000);
        bytes32[] memory newSocials = new bytes32[](3);
        newSocials[0] = bytes32(0x0107000000000000000000000000000000000000000000000000000000000000);
        newSocials[1] = bytes32(0x0108000000000000000000000000000000000000000000000000000000000000);
        newSocials[2] = bytes32(0x0201000000000000000000000000000000000000000000000000000000000000); // member2 owns
        try community.updateSocials(address(member1), oldSocials, newSocials) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "username already registered", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function checkThereIsAMaxLimitForRegistrations() public {
        // fill up registry
        for (uint i=communityStorage.getMemberCount(); i<community.MAX_MEMBERS(); i++) {
            community.registerMember(address(uint160(i+2)), address(1), new bytes32[](0));
        }
        Assert.equal(communityStorage.getMemberCount(), community.MAX_MEMBERS(), 'member count should be maximum');
        try community.registerMember(address(uint160(community.MAX_MEMBERS()+2)), address(1), new bytes32[](0)) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "membership full", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

}
