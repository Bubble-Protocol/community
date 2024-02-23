import { assert } from "@bubble-protocol/client";
import { ecdsa } from "@bubble-protocol/crypto";

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

  async mint(account, amount) {
    console.trace('minting', amount, 'tokens for', account);
    ecdsa.assert.isAddress(account, 'account');
    assert.isNumber(amount, 'amount');
    return this.wallet.estimateAndSend(this.contract.address, this.contract.abi, 'mint', [account, amount]);
  }

  async batchMint(batch) {
    console.trace('minting batch', JSON.stringify(batch));
    assert.isArray(batch, 'batch');
    return this.wallet.estimateAndSend(this.contract.address, this.contract.abi, 'mintBatch', [batch]);
  }

}