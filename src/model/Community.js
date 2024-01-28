import { assert } from "@bubble-protocol/client";
import { keccak256 } from "viem";
import { stateManager } from "../state-context";

export class Community {

  wallet;
  contract;
  blockchainStats = {
    memberCount: 0
  }

  constructor(config, wallet) {
    this.wallet = wallet;
    this.contract = config.contract;
    stateManager.register('communityStats', {...this.blockchainStats});
    this.register = this.register.bind(this);
  }

  initialise() {
    this.getMemberCount();
  }

  async _getMemberCount() {
    return this.wallet.call(this.contract.address, this.contract.abi, 'memberCount')
    .then(count => this._setBlockchainStat('memberCount', count));
  }

  async isMember(account) {
    return this.wallet.call(this.contract.address, this.contract.abi, 'isMember', [account]);
  }

  async register(details) {
    const account = this.wallet.account;
    console.log("registering user:", account, details);
    assert.isObject(details, 'details');
    if (!details.twitter) return Promise.reject('missing twitter username');
    if (!details.discord) return Promise.reject('missing discord username');
    if (!details.telegram) return Promise.reject('missing telegram username');
    const socialHashes = [keccak256('twitter:'+details.twitter), keccak256('discord:'+details.discord), keccak256('telegram:'+details.telegram)];
    console.log("registering on blockchain:", account, socialHashes);
    return this.wallet.send(this.contract.address, this.contract.abi, 'registerAsMember', [socialHashes])
    .then(() => this.isMember(account))
  }

  _setBlockchainStat(stat, value) {
    this.blockchainStats[stat] = value;
    stateManager.dispatch('communityStats', {...this.blockchainStats});
    return value;
  }
}