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

  async register(loginAddress, details) {
    const account = this.wallet.account;
    console.log("registering user:", account, details);
    assert.isObject(details, 'details');
    if (!details.twitter) return Promise.reject('missing twitter username');
    if (!details.discord) return Promise.reject('missing discord username');
    if (!details.telegram) return Promise.reject('missing telegram username');
    const socialHashes = constructSocials(details);
    console.log("registering on blockchain:", account, socialHashes);
    return this.wallet.estimateAndSend(this.contract.address, this.contract.abi, 'registerAsMember', [loginAddress, socialHashes]);
  }

  async updateSocials(oldDetails, newDetails) {
    const account = this.wallet.account;
    console.log("updating member details:", account, oldDetails, newDetails);
    assert.isObject(oldDetails, 'oldDetails');
    assert.isObject(newDetails, 'newDetails');
    const oldSocialHashes = constructSocials(oldDetails);
    const newSocialHashes = constructSocials(newDetails);
    console.log("updating on blockchain:", account, oldSocialHashes, newSocialHashes);
    return this.wallet.estimateAndSend(this.contract.address, this.contract.abi, 'updateSocials', [oldSocialHashes, newSocialHashes]);
  }

  _setBlockchainStat(stat, value) {
    this.blockchainStats[stat] = value;
    stateManager.dispatch('communityStats', {...this.blockchainStats});
    return value;
  }
}


function constructSocials(details) {
  const socialHashes = [];
  if (details.twitter) socialHashes.push(keccak256('twitter:'+details.twitter));
  if (details.discord) socialHashes.push(keccak256('discord:'+details.discord));
  if (details.telegram) socialHashes.push(keccak256('telegram:'+details.telegram));
  return socialHashes;
}