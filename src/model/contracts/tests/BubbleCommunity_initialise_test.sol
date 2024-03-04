// SPDX-License-Identifier: GPL-3.0
        
pragma solidity 0.8.24;

// This import is automatically injected by Remix
import "remix_tests.sol"; 

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import {BubbleCommunity, BubbleCommunityImplementation, Mintable} from "../BubbleCommunity.sol";
import {CommunityUser} from "./CommunityUser.sol";
import {BubblePreGovernanceToken} from "../tokens/BubblePreGovernanceToken.sol";

contract testSuite {

    address owner = address(this);
    CommunityUser member1;
    CommunityUser member2;
    CommunityUser memberAdmin;
    CommunityUser nftAdmin;

    BubbleCommunity communityStorage;
    BubbleCommunityImplementation implementation;
    BubbleCommunityImplementation community;
    BubblePreGovernanceToken communityToken;

    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    /// #sender: account-0
    function beforeAll() public {
        // Construct storage contract
        communityStorage = new BubbleCommunity();
        Assert.equal(communityStorage.storageContract(), address(communityStorage), "storageContract should be the address of itself");
        Assert.equal(communityStorage.implementationContract(), address(0), "implementationContract should be zero by default");
        Assert.equal(communityStorage.owner(), owner, "owner should be the address that constructed the contract");
        Assert.equal(communityStorage.initialised(), false, "community should be uninitialised by default");
        // Construct implementation contract and upgrade storage contract
        implementation = new BubbleCommunityImplementation();
        communityStorage.upgradeImplementation(address(implementation));
        Assert.equal(communityStorage.storageContract(), address(communityStorage), "storageContract should be unchanged after upgrade");
        Assert.equal(communityStorage.implementationContract(), address(implementation), "implementationContract should be set to the upgrade contract address");
        Assert.equal(communityStorage.owner(), owner, "owner should not have changed after upgrade");
        Assert.equal(communityStorage.initialised(), false, "community should be uninitialised after upgrade");
        // Recast implementation contract
        community = BubbleCommunityImplementation(address(communityStorage));
        Assert.equal(community.storageContract(), address(communityStorage), "storageContract should be accessible through recast implementation");
        Assert.equal(community.implementationContract(), address(implementation), "implementationContract should be accessible through recast implementation");
        Assert.equal(community.owner(), owner, "owner should be accessible through recast implementation");
        Assert.equal(community.initialised(), false, "initialised should be accessible through recast implementation");
        // Initialise upgraded contract
        communityToken = new BubblePreGovernanceToken("community token", "CT", community);
        community.initialise(Mintable(address(communityToken)));
        Assert.equal(community.initialised(), true, "community should be initialised after calling initialise");
        // Construct test members and admins
        member1 = new CommunityUser(community);
        member2 = new CommunityUser(community);
        memberAdmin = new CommunityUser(community);
        nftAdmin = new CommunityUser(community);
    }

    /// Check owner has all the right roles
    function checkOwnerRoles() public {
        Assert.ok(community.hasRole(community.DEFAULT_ADMIN_ROLE(), owner), 'owner should have admin role');
        Assert.ok(community.hasRole(community.MEMBER_ADMIN_ROLE(), owner), 'owner should have member admin role');
        Assert.ok(community.hasRole(community.NFT_ADMIN_ROLE(), owner), 'owner should have nft admin role');
    }

    /// Check other members have no roles
    function checkMemberRoles() public {
        Assert.equal(community.hasRole(community.DEFAULT_ADMIN_ROLE(), address(member1)), false, 'member1 should not have admin role');
        Assert.equal(community.hasRole(community.MEMBER_ADMIN_ROLE(), address(member1)), false, 'member1 should not have member admin role');
        Assert.equal(community.hasRole(community.NFT_ADMIN_ROLE(), address(member1)), false, 'member1 should not have nft admin role');
        Assert.equal(community.hasRole(community.DEFAULT_ADMIN_ROLE(), address(member2)), false, 'member2 should not have admin role');
        Assert.equal(community.hasRole(community.MEMBER_ADMIN_ROLE(), address(member2)), false, 'member2 should not have member admin role');
        Assert.equal(community.hasRole(community.NFT_ADMIN_ROLE(), address(member2)), false, 'member2 should not have nft admin role');
        Assert.equal(community.hasRole(community.DEFAULT_ADMIN_ROLE(), address(memberAdmin)), false, 'memberAdmin should not have admin role');
        Assert.equal(community.hasRole(community.MEMBER_ADMIN_ROLE(), address(memberAdmin)), false, 'memberAdmin should not have member admin role');
        Assert.equal(community.hasRole(community.NFT_ADMIN_ROLE(), address(memberAdmin)), false, 'memberAdmin should not have nft admin role');
        Assert.equal(community.hasRole(community.DEFAULT_ADMIN_ROLE(), address(nftAdmin)), false, 'nftAdmin should not have admin role');
        Assert.equal(community.hasRole(community.MEMBER_ADMIN_ROLE(), address(nftAdmin)), false, 'nftAdmin should not have member admin role');
        Assert.equal(community.hasRole(community.NFT_ADMIN_ROLE(), address(nftAdmin)), false, 'nftAdmin should not have nft admin role');
    }

    function checkInitialisedState() public {
        Assert.equal(community.getMemberCount(), 0, 'member count should be zero');
        Assert.equal(community.getNFTs().length, 0, 'nft list should be empty');
    }

}
