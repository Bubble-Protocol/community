// SPDX-License-Identifier: GPL-3.0
        
pragma solidity 0.8.24;

import "./BubbleCommunity_test_common.sol";
import {BubblePreGovernanceToken, Mint} from "../tokens/BubblePreGovernanceToken.sol";

contract testSuite is testSuite_template {

    BubblePreGovernanceToken token;
    address[] registeredAddresses = new address[](50);
    address additionalUser;
    address loginAddress = address(1001);

    function beforeAll() public {
        init();
        token = new BubblePreGovernanceToken("my token", "token", community);
        Assert.equal(token.totalSupply(), 0, "unexpected token count");
        bytes32[TEST_MAX_SOCIALS] memory socials;
        for (uint i=0; i<registeredAddresses.length; i++) {
            registeredAddresses[i] = address(uint160(i+2));
            socials[0] = bytes32(1000000+i);
            socials[1] = bytes32(2000000+i);
            socials[2] = bytes32(3000000+i);
            community.registerMember(registeredAddresses[i], loginAddress, socials);
            Assert.ok(community.isMember(registeredAddresses[i]), 'not a member');
        }
    }

    function canGetMemberRegistry() public {
        Assert.equal(address(token.getMemberRegistry()), address(community), "registry incorrect");
    }

    function canMintBatch() public {
        Mint[] memory batch = new Mint[](registeredAddresses.length);
        uint total = 0;
        for (uint i=0; i<registeredAddresses.length; i++) {
            batch[i] = Mint(registeredAddresses[i], i+1);
            total += i+1;
        }
        token.mintBatch(batch);
        Assert.equal(token.totalSupply(), total, "unexpected token count");
        for (uint i=0; i<registeredAddresses.length; i++) {
            Assert.equal(token.balanceOf(registeredAddresses[i]), i+1, 'member balance incorrect');
        }
    }

    function canMintBatchAgain() public {
        Mint[] memory batch = new Mint[](registeredAddresses.length);
        uint total = token.totalSupply();
        for (uint i=0; i<registeredAddresses.length; i++) {
            batch[i] = Mint(registeredAddresses[i], i+1);
            total += i+1;
        }
        token.mintBatch(batch);
        Assert.equal(token.totalSupply(), total, "unexpected token count");
        for (uint i=0; i<registeredAddresses.length; i++) {
            Assert.equal(token.balanceOf(registeredAddresses[i]), 2*(i+1), 'member balance incorrect');
        }
    }

    function canMint() public {
        uint supply = token.totalSupply();
        uint balance = token.balanceOf(registeredAddresses[0]);
        token.mint(registeredAddresses[0], 17);
        Assert.equal(token.totalSupply(), supply+17, "unexpected token count");
        Assert.equal(token.balanceOf(registeredAddresses[0]), balance+17, 'member balance incorrect');
    }

    function canMintAgain() public {
        uint supply = token.totalSupply();
        uint balance = token.balanceOf(registeredAddresses[0]);
        token.mint(registeredAddresses[0], 17);
        Assert.equal(token.totalSupply(), supply+17, "unexpected token count");
        Assert.equal(token.balanceOf(registeredAddresses[0]), balance+17, 'member balance incorrect');
    }

    function tryToMintForNonMember() public {
        address unregisteredAddress = address(uint160(1000));
        try token.mint(unregisteredAddress, 1) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "not a community member", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToMintBatchForNonMember() public {
        address unregisteredAddress = address(uint160(1000));
        Mint[] memory batch = new Mint[](1);
        batch[0] = Mint(unregisteredAddress, 1);
        try token.mintBatch(batch) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "not a community member", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function checkNonTransferable() public {
        address to = address(uint160(1000));
        try token.transfer(to, 1) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "tokens are non-transferable", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
        try token.transferFrom(registeredAddresses[0], to, 1) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "tokens are non-transferable", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function checkNonApprovable() public {
        address to = address(uint160(1000));
        try token.approve(to, 1) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "tokens are non-transferable", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToCallMintWithoutOwnerRole() public {
        try member1.mintToken(token, address(member1), 1) {
            Assert.ok(false, "method should revert");
        } catch (bytes memory reason) {
            assertOwnableUnauthorizedAccountError(reason);
        }
    }

    function tryToCallMintBatchWithoutOwnerRole() public {
        Mint[] memory batch = new Mint[](1);
        batch[0] = Mint(address(member1), 1);
        try member1.mintBatchToken(token, batch) {
            Assert.ok(false, "method should revert");
        } catch (bytes memory reason) {
            assertOwnableUnauthorizedAccountError(reason);
        }
    }

    function tryToCallCloseWithoutOwnerRole() public {
        try member1.closeToken(token) {
            Assert.ok(false, "method should revert");
        } catch (bytes memory reason) {
            assertOwnableUnauthorizedAccountError(reason);
        }
    }

    function checkOwnerCanClose() public {
        Assert.equal(token.isClosed(), false, 'token should not be closed before test');
        token.close();
        Assert.equal(token.isClosed(), true, 'token should be closed');
    }

    function checkMintingDisallowedWhenClosed() public {
        try token.mint(registeredAddresses[0], 1) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "round is closed", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function checkBatchMintingDisallowedWhenClosed() public {
        Mint[] memory batch = new Mint[](1);
        batch[0] = Mint(registeredAddresses[0], 1);
        try token.mintBatch(batch) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "round is closed", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

}
