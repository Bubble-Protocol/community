import * as communityAbi from "../contracts/BubbleCommunity_abi.json";

export const DEFAULT_CONFIG = {
  chain: "polygon",
  community: {
    contract: {
      address: "0x0Faa4bBE6b9B521D9160216336541c627eadF897",
      abi: communityAbi.default
    }
  }
}