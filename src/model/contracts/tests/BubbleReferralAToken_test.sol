// SPDX-License-Identifier: GPL-3.0
        
pragma solidity 0.8.24;

import "./BubbleCommunity_test_common.sol";
import {BubbleReferralAToken} from "../tokens/BubbleReferralAToken.sol";

contract testSuite is testSuite_template {

    BubbleReferralAToken nft;
    address[] registeredAddresses = new address[](50);
    address additionalUser;
    address loginAddress = address(1001);

    function beforeAll() public {
        init();
        nft = new BubbleReferralAToken("my nft", "nft", "url", community);
        Assert.equal(nft.tokenCount(), 0, "unexpected token count");
        bytes32[TEST_MAX_SOCIALS] memory socials;
        for (uint i=0; i<registeredAddresses.length; i++) {
            registeredAddresses[i] = address(uint160(i+2));
            socials[0] = bytes32(1000000+i);
            socials[1] = bytes32(2000000+i);
            socials[2] = bytes32(3000000+i);
            community.registerMember(registeredAddresses[i], loginAddress, socials);
        }
    }

    function canGetMemberRegistry() public {
        Assert.equal(address(nft.getMemberRegistry()), address(community), "registry incorrect");
    }

    function canMintBatch() public {
        nft.mintBatch(registeredAddresses);
        Assert.equal(nft.tokenCount(), registeredAddresses.length, "unexpected token count");
    }

    function canMint() public {
        additionalUser = address(uint160(registeredAddresses.length+2));
        bytes32[TEST_MAX_SOCIALS] memory socials;
        socials[0] = bytes32(uint256(11000000));
        socials[1] = bytes32(uint256(12000000));
        socials[2] = bytes32(uint256(13000000));
        community.registerMember(additionalUser, loginAddress, socials);
        nft.mint(additionalUser);
        Assert.equal(nft.tokenCount(), registeredAddresses.length+1, "unexpected token count");
    }

    function checkSameUriForEveryToken() public {
        Assert.equal(nft.tokenURI(0), "url", 'min uri incorrect');
        Assert.equal(nft.tokenURI(registeredAddresses.length-1), "url", 'max uri incorrect');
    }

    function tryToMintForSameMemberTwice() public {
        try nft.mint(additionalUser) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "already an owner", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToMintBatchForSameMemberTwice() public {
        try nft.mintBatch(registeredAddresses) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "already an owner", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToMintForNonMember() public {
        address unregisteredAddress = address(uint160(1000));
        try nft.mint(unregisteredAddress) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "not a community member", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToMintBatchForNonMember() public {
        address unregisteredAddress = address(uint160(1000));
        address[] memory batch = new address[](1);
        batch[0] = unregisteredAddress;
        try nft.mintBatch(batch) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "not a community member", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function checkNonTransferable() public {
        uint tokenId = 0;
        address to = address(uint160(1000));
        try nft.transferFrom(registeredAddresses[0], to, tokenId) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "tokens are non-transferable", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
        try nft.safeTransferFrom(registeredAddresses[0], to, tokenId) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "tokens are non-transferable", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function checkNonApprovable() public {
        uint tokenId = 0;
        address to = address(uint160(1000));
        try nft.approve(to, tokenId) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "tokens are non-transferable", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
        try nft.setApprovalForAll(to, true) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "tokens are non-transferable", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToCallMintWithoutOwnerRole() public {
        try member1.mintNft(nft, address(member1)) {
            Assert.ok(false, "method should revert");
        } catch (bytes memory reason) {
            assertOwnableUnauthorizedAccountError(reason);
        }
    }

    function tryToCallMintBatchWithoutOwnerRole() public {
        try member1.mintBatchNft(nft, registeredAddresses) {
            Assert.ok(false, "method should revert");
        } catch (bytes memory reason) {
            assertOwnableUnauthorizedAccountError(reason);
        }
    }

    function tryToCallCloseWithoutOwnerRole() public {
        try member1.closeNft(nft) {
            Assert.ok(false, "method should revert");
        } catch (bytes memory reason) {
            assertOwnableUnauthorizedAccountError(reason);
        }
    }

    function checkOwnerCanClose() public {
        Assert.equal(nft.isClosed(), false, 'token should not be closed before test');
        nft.close();
        Assert.equal(nft.isClosed(), true, 'token should be closed');
    }

    function checkMintingDisallowedWhenClosed() public {
        try nft.mint(registeredAddresses[0]) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "round is closed", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function checkBatchMintingDisallowedWhenClosed() public {
        try nft.mintBatch(registeredAddresses) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "round is closed", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }


}
