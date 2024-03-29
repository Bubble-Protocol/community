// SPDX-License-Identifier: GPL-3.0
        
pragma solidity 0.8.24;

import "./BubbleCommunity_test_common.sol";
import {BubbleReferralAToken} from "../tokens/BubbleReferralAToken.sol";

contract testSuite is testSuite_template {

    BubbleReferralAToken nftContract1;
    BubbleReferralAToken nftContract2;
    BubbleReferralAToken nftContract3;
    BubbleReferralAToken nftContract4;

    function beforeAll() public {
        init();
    }

    function registerNFT() public {
        uint prevNftCount = community.getNFTs().length;
        nftContract1 = new BubbleReferralAToken("my nft", "NFT", "url", community);
        Assert.equal(community.hasNFT(address(nftContract1)), false, 'nft should not be registered before test');
        community.registerNFT(address(nftContract1));
        Assert.equal(community.hasNFT(address(nftContract1)), true, 'nft should be registered');
        Assert.equal(community.getNFTs().length, prevNftCount+1, 'nft count should have increased by one');
        Assert.equal(community.getNFTs()[0], address(nftContract1), 'nft contract address is incorrect');
    }

    function tryToRegisterNftTwice() public {
        try community.registerNFT(address(nftContract1)) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "already registered", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

    function deregisterNFT() public {
        nftContract2 = new BubbleReferralAToken("my nft 2", "NFT2", "url2", community);
        community.registerNFT(address(nftContract2));
        nftContract3 = new BubbleReferralAToken("my nft 3", "NFT3", "url3", community);
        community.registerNFT(address(nftContract3));
        nftContract4 = new BubbleReferralAToken("my nft 4", "NFT4", "url4", community);
        community.registerNFT(address(nftContract4));
        Assert.equal(community.getNFTs().length, 4, 'nft count should be 4 before test');
        Assert.equal(community.hasNFT(address(nftContract1)), true, 'nft 1 should be registered');
        Assert.equal(community.hasNFT(address(nftContract2)), true, 'nft 2 should be registered');
        Assert.equal(community.hasNFT(address(nftContract3)), true, 'nft 3 should be registered');
        Assert.equal(community.hasNFT(address(nftContract4)), true, 'nft 4 should be registered');
        community.deregisterNFT(address(nftContract2));
        Assert.equal(community.getNFTs().length, 3, 'nft count should have decreased by one');
        Assert.equal(community.hasNFT(address(nftContract1)), true, 'nft 1 should be registered');
        Assert.equal(community.hasNFT(address(nftContract2)), false, 'nft 2 should not be registered');
        Assert.equal(community.hasNFT(address(nftContract3)), true, 'nft 3 should be registered');
        Assert.equal(community.hasNFT(address(nftContract4)), true, 'nft 4 should be registered');
        Assert.equal(community.getNFTs()[0], address(nftContract1), 'nft 1 contract address is incorrect');
        Assert.equal(community.getNFTs()[1], address(nftContract4), 'nft 4 contract address is incorrect');
        Assert.equal(community.getNFTs()[2], address(nftContract3), 'nft 3 contract address is incorrect');
    }

    function tryToDeregisterUnregisteredNft() public {
        try community.deregisterNFT(address(nftContract2)) {
            Assert.ok(false, "method should revert");
        } catch Error(string memory reason) {
            Assert.equal(reason, "nft not registered", "expected revert message incorrect");
        } catch (bytes memory /*lowLevelData*/) {
            Assert.ok(false, "failed unexpected");
        }
    }

}
