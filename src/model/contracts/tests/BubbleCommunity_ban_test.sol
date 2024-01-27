// SPDX-License-Identifier: GPL-3.0
        
pragma solidity 0.8.24;

import "./BubbleCommunity_test_common.sol";

contract testSuite is testSuite_template {

    bytes32[] member1Socials = new bytes32[](3);
    bytes32[] member2Socials = new bytes32[](1);

    function beforeAll() public {
        init();
        member1Socials[0] = bytes32(0x0101000000000000000000000000000000000000000000000000000000000000);
        member1Socials[1] = bytes32(0x0102000000000000000000000000000000000000000000000000000000000000);
        member1Socials[2] = bytes32(0x0103000000000000000000000000000000000000000000000000000000000000);
        member1.registerAsMember(member1Socials);
        member2Socials[0] = bytes32(0x0201000000000000000000000000000000000000000000000000000000000000);
        community.registerMember(address(member2), member2Socials);
        Assert.equal(communityStorage.getMemberCount(), 2, 'member count should be two');
    }

    function banMember1() public {
        uint prevMemberCount = communityStorage.getMemberCount();
        community.banMember(address(member1), member1Socials);
        Assert.equal(communityStorage.getMemberCount(), prevMemberCount-1, 'member count should have decreased by one');
        Assert.equal(communityStorage.isMember(address(member1)), false, 'isMember should be false after deregistering');
        Assert.equal(communityStorage.getUserAddress(member1Socials[0]), address(1), 'social 0 owner should be one after banning');
        Assert.equal(communityStorage.getUserAddress(member1Socials[1]), address(1), 'social 1 owner should be one after banning');
        Assert.equal(communityStorage.getUserAddress(member1Socials[2]), address(1), 'social 2 owner should be one after banning');
    }

    function tryToReregisterAsMember() public {
        Assert.equal(communityStorage.isMember(address(member1)), false, 'member must be unregistered before test');
        try member1.registerAsMember(member1Socials) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "username banned", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToReregisterAsAdmin() public {
        Assert.equal(communityStorage.isMember(address(member1)), false, 'member must be unregistered before test');
        try community.registerMember(address(member1), member1Socials) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "username banned", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function unbanMember1Socials() public {
        Assert.equal(communityStorage.getUserAddress(member1Socials[0]), address(1), 'social 0 owner must be banned before test');
        uint prevMemberCount = communityStorage.getMemberCount();
        community.unbanSocials(member1Socials);
        Assert.equal(communityStorage.getMemberCount(), prevMemberCount, 'member count should be unchanged after unbanning');
        Assert.equal(communityStorage.getUserAddress(member1Socials[0]), address(0), 'social 0 owner should be zero after unbanning');
        Assert.equal(communityStorage.getUserAddress(member1Socials[1]), address(0), 'social 1 owner should be zero after unbanning');
        Assert.equal(communityStorage.getUserAddress(member1Socials[2]), address(0), 'social 2 owner should be zero after unbanning');
    }

    function ensureMember1CanReregisterAfterUnbanning() public {
        Assert.equal(communityStorage.isMember(address(member1)), false, 'isMember should be false before registering');
        uint prevMemberCount = communityStorage.getMemberCount();
        member1.registerAsMember(member1Socials);
        Assert.equal(communityStorage.getMemberCount(), prevMemberCount+1, 'member count should have increased by one');
        Assert.equal(communityStorage.isMember(address(member1)), true, 'isMember should be true after registering');
        Assert.equal(communityStorage.getUserAddress(member1Socials[0]), address(member1), 'social 0 owner should be member after registering');
        Assert.equal(communityStorage.getUserAddress(member1Socials[1]), address(member1), 'social 1 owner should be member after registering');
        Assert.equal(communityStorage.getUserAddress(member1Socials[2]), address(member1), 'social 2 owner should be member after registering');
    }

    function banMember1EvenIfUnregistered() public {
        Assert.equal(communityStorage.isMember(address(member1)), true, 'isMember must be true before test');
        member1.deregisterAsMember(new bytes32[](0));
        Assert.equal(communityStorage.isMember(address(member1)), false, 'isMember should be false after deregistering');
        Assert.equal(communityStorage.getUserAddress(member1Socials[0]), address(member1), 'social 0 owner should still be member after deregistering');
        Assert.equal(communityStorage.getUserAddress(member1Socials[1]), address(member1), 'social 1 owner should still be member after deregistering');
        Assert.equal(communityStorage.getUserAddress(member1Socials[2]), address(member1), 'social 2 owner should still be member after deregistering');
        // Banning socials left hanging by user requires first deregistering the socials then banning them
        community.updateSocials(address(member1), member1Socials, new bytes32[](0));
        community.banSocials(member1Socials);
        Assert.equal(communityStorage.getUserAddress(member1Socials[0]), address(1), 'social 0 owner should be one after banning');
        Assert.equal(communityStorage.getUserAddress(member1Socials[1]), address(1), 'social 1 owner should be one after banning');
        Assert.equal(communityStorage.getUserAddress(member1Socials[2]), address(1), 'social 2 owner should be one after banning');
    }


}
