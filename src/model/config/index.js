import * as communityAbi from "../contracts/BubbleCommunity_abi.json";

export const DEFAULT_CONFIG = {
  appId: 'bubble-community',
  contract: {
    chain: 137,
    address: '0xdE2952317B2F653aB8c4C84F6F6a55246096096F',
    abi: communityAbi.default
  },
  bubble: {
    adminPublicKey: '0x020ca76933ec34c4035aeb3a5d91538a2f0979baadcd796d23019e39308ba5e419',
    provider: "https://vault.bubbleprotocol.com/v2/polygon",
  }
}
