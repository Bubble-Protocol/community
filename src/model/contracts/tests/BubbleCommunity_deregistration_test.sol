// SPDX-License-Identifier: GPL-3.0
        
pragma solidity 0.8.24;

import "./BubbleCommunity_test_common.sol";

contract testSuite is testSuite_template {

    bytes32[] member1Socials = new bytes32[](3);
    bytes32[] member2Socials = new bytes32[](3);

    function beforeAll() public {
        init();
        member1Socials[0] = bytes32(0x0101000000000000000000000000000000000000000000000000000000000000);
        member1Socials[1] = bytes32(0x0102000000000000000000000000000000000000000000000000000000000000);
        member1Socials[2] = bytes32(0x0103000000000000000000000000000000000000000000000000000000000000);
        member1.registerAsMember(member1Socials);
        member2Socials[0] = bytes32(0x0201000000000000000000000000000000000000000000000000000000000000);
        member2Socials[1] = bytes32(0x0202000000000000000000000000000000000000000000000000000000000000);
        member2Socials[2] = bytes32(0x0203000000000000000000000000000000000000000000000000000000000000);
        member2.registerAsMember(member2Socials);
        Assert.equal(communityStorage.getMemberCount(), 2, 'member count should be two');
    }

    function deregisterMember1AsUser() public {
        uint prevMemberCount = communityStorage.getMemberCount();
        member1.deregisterAsMember();
        Assert.equal(communityStorage.getMemberCount(), prevMemberCount-1, 'member count should have decreased by one');
        Assert.equal(communityStorage.isMember(address(member1)), false, 'isMember should be false after deregistering');
        Assert.equal(communityStorage.getUserAddress(member1Socials[0]), address(0), 'social 0 owner should be zero after registering');
        Assert.equal(communityStorage.getUserAddress(member1Socials[1]), address(0), 'social 1 owner should be zero after registering');
        Assert.equal(communityStorage.getUserAddress(member1Socials[2]), address(0), 'social 2 owner should be zero after registering');
    }

    function deregisterMember2AsAdmin() public {
        uint prevMemberCount = communityStorage.getMemberCount();
        community.deregisterMember(address(member2));
        Assert.equal(communityStorage.getMemberCount(), prevMemberCount-1, 'member count should have decreased by one');
        Assert.equal(communityStorage.isMember(address(member2)), false, 'isMember should be false after deregistering');
        Assert.equal(communityStorage.getUserAddress(member2Socials[0]), address(0), 'social 0 owner should be zero after registering');
    }

    function tryToDeregisterAnUnregisteredMember() public {
        Assert.equal(communityStorage.isMember(address(member2)), false, 'member must be unregistered before test');
        try member2.deregisterAsMember() {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "not a member", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToDeregisterAnUnregisteredMemberAsAdmin() public {
        Assert.equal(communityStorage.isMember(address(member2)), false, 'member must be unregistered before test');
        try community.deregisterMember(address(member2)) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "not a member", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

}
