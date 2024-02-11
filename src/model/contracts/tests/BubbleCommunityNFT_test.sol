// SPDX-License-Identifier: GPL-3.0
        
pragma solidity 0.8.24;

import "./BubbleCommunity_test_common.sol";
import {BubbleCommunityNFT} from "../tokens/BubbleCommunityNFT.sol";

contract testSuite is testSuite_template {

    BubbleCommunityNFT nft;
    uint256 TOTAL_CAP = 61;
    address[] registeredAddresses = new address[](50);
    address[] additionalAddresses = new address[](10);
    address additionalUser;
    address loginAddress = address(1001);

    function beforeAll() public {
        init();
        nft = new BubbleCommunityNFT("my nft", "nft", "url", TOTAL_CAP, community);
        Assert.equal(nft.tokenCount(), 0, "unexpected token count");
        bytes32[TEST_MAX_SOCIALS] memory socials;
        for (uint i=0; i<registeredAddresses.length; i++) {
            registeredAddresses[i] = address(uint160(i+2));
            socials[0] = bytes32(1000000+i);
            socials[1] = bytes32(2000000+i);
            socials[2] = bytes32(3000000+i);
            community.registerMember(registeredAddresses[i], loginAddress, socials);
        }
        for (uint i=0; i<additionalAddresses.length; i++) {
            additionalAddresses[i] = address(uint160(registeredAddresses.length+i+4));
            socials[0] = bytes32(1000000+registeredAddresses.length+i);
            socials[1] = bytes32(2000000+registeredAddresses.length+i);
            socials[2] = bytes32(3000000+registeredAddresses.length+i);
            community.registerMember(additionalAddresses[i], loginAddress, socials);
        }
        socials[0] = bytes32(uint256(11000001));
        socials[1] = bytes32(uint256(12000001));
        socials[2] = bytes32(uint256(13000001));
        community.registerMember(address(member1), loginAddress, socials);
        socials[0] = bytes32(uint256(11000002));
        socials[1] = bytes32(uint256(12000002));
        socials[2] = bytes32(uint256(13000002));
        community.registerMember(address(member2), loginAddress, socials);
    }

    function canGetMemberRegistry() public {
        Assert.equal(address(nft.getMemberRegistry()), address(community), "registry incorrect");
    }

    function canGetTotalCap() public {
        Assert.equal(nft.totalCap(), TOTAL_CAP, "cap incorrect");
    }

    function canMintBatch() public {
        nft.mintBatch(registeredAddresses);
        Assert.equal(nft.tokenCount(), registeredAddresses.length, "unexpected token count");
    }

    function canMintAsAdmin() public {
        additionalUser = address(uint160(registeredAddresses.length+2));
        bytes32[TEST_MAX_SOCIALS] memory socials;
        socials[0] = bytes32(uint256(11000000));
        socials[1] = bytes32(uint256(12000000));
        socials[2] = bytes32(uint256(13000000));
        community.registerMember(additionalUser, loginAddress, socials);
        nft.mint(additionalUser);
        Assert.equal(nft.tokenCount(), registeredAddresses.length+1, "unexpected token count");
    }

    function canMintAsMember() public {
        member1.mintNft(nft);
        Assert.equal(nft.tokenCount(), registeredAddresses.length+2, "unexpected token count");
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
        address[] memory batch = new address[](2);
        batch[0] = registeredAddresses[0];
        batch[1] = registeredAddresses[1];
        try nft.mintBatch(batch) {
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

    function tryToMintBatchBeyondTotalCap() public {
        try nft.mintBatch(additionalAddresses) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "not enough tokens left", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToMintBeyondTotalCapAsMember() public {
        address[] memory batch = new address[](additionalAddresses.length-1);
        for (uint i=0; i<additionalAddresses.length-1; i++) {
            batch[i] = additionalAddresses[i];
        }
        nft.mintBatch(batch);
        try member2.mintNft(nft) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "no tokens left", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function tryToMintBeyondTotalCapAsAdmin() public {
        try nft.mint(additionalAddresses[additionalAddresses.length-1]) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "no tokens left", "expected revert message incorrect");
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
