import * as communityAbi from "../contracts/BubbleCommunity_abi.json";
import * as nftAbi from "../contracts/BubbleCommunityNFT_abi.json";
import * as preGovTokenAbi from "../contracts/BubblePreGovernanceToken_abi.json";

export const DEFAULT_CONFIG = {
  appId: 'bubble-community',
  community: {
    contract: {
      chain: 137,
      address: '0xfF0795db0D1B09c00F9B01b23a1ff6b7556daA6F',
      abi: communityAbi.default
    },
    nftContract: {
      chain: 137,
      abi: nftAbi.default
    },
    bubble: {
      adminPublicKey: '0x020ca76933ec34c4035aeb3a5d91538a2f0979baadcd796d23019e39308ba5e419',
      provider: "https://vault.bubbleprotocol.com/v2/polygon",
    },
  },
  preGovToken: {
    contract: {
      chain: 137,
      address: '0xEf9eD7fdAB95b8Bc02CFe05d869c3e08E7F102d1',
      abi: preGovTokenAbi.default  
    }
  }
}
