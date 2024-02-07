/**
 * Wrapper for the BubblePreGovernanceToken smart contract
 */
export class PreGovernanceToken {

  contract;
  wallet;

  constructor(config, wallet) {
    this.wallet = wallet;
    this.contract = config.contract;
  }

  async balanceOf(member) {
    return this.wallet.call(this.contract.address, this.contract.abi, 'balanceOf', [member]);
  }

}