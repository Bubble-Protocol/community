// SPDX-License-Identifier: GPL-3.0
        
pragma solidity 0.8.24;

import "./BubbleCommunity_test_common.sol";
import {BubbleReferralAToken} from "../nfts/BubbleReferralAToken.sol";

contract testSuite is testSuite_template {

    BubbleReferralAToken nft;
    address[] registeredAddresses = new address[](50);
    address additionalUser;

    function beforeAll() public {
        init();
        nft = new BubbleReferralAToken("my nft", "nft", "url", communityStorage);
        Assert.equal(nft.tokenCount(), 0, "unexpected token count");
        for (uint i=0; i<registeredAddresses.length; i++) {
            registeredAddresses[i] = address(uint160(i+2));
            community.registerMember(registeredAddresses[i], new bytes32[](0));
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
        community.registerMember(additionalUser, new bytes32[](0));
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
        try member1.mint(nft, address(member1)) {
            Assert.ok(false, "method should revert");
        } catch (bytes memory reason) {
            assertOwnableUnauthorizedAccountError(reason);
        }
    }

    function tryToCallMintBatchWithoutOwnerRole() public {
        try member1.mintBatch(nft, registeredAddresses) {
            Assert.ok(false, "method should revert");
        } catch (bytes memory reason) {
            assertOwnableUnauthorizedAccountError(reason);
        }
    }

    function tryToCallCloseWithoutOwnerRole() public {
        try member1.close(nft) {
            Assert.ok(false, "method should revert");
        } catch (bytes memory reason) {
            assertOwnableUnauthorizedAccountError(reason);
        }
    }


}
