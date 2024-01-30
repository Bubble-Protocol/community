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
    details = validateSocials(details);
    if (!details.twitter) return Promise.reject('missing twitter username');
    if (!details.discord) return Promise.reject('missing discord username');
    if (!details.telegram) return Promise.reject('missing telegram username');
    const socialHashes = constructSocials(details);
    console.log("registering on blockchain:", account, socialHashes);
    return this.wallet.estimateAndSend(this.contract.address, this.contract.abi, 'registerAsMember', [loginAddress, socialHashes]);
  }

  async deregister(account, details, force=false) {
    console.log("deregistering user:", account, details);
    const walletAccount = this.wallet.account;
    if (walletAccount.toLowerCase() !== account.toLowerCase()) return Promise.reject('wallet account does not match requested account');
    assert.isObject(details, 'details');
    details = validateSocials(details);
    if (!force) {
      if (!details.twitter) return Promise.reject('missing twitter username');
      if (!details.discord) return Promise.reject('missing discord username');
      if (!details.telegram) return Promise.reject('missing telegram username');
    }
    const socialHashes = constructSocials(details);
    console.log("deregistering on blockchain:", account, socialHashes);
    return this.wallet.estimateAndSend(this.contract.address, this.contract.abi, 'deregisterAsMember', [socialHashes]);
  }

  async updateSocials(oldDetails, newDetails) {
    const account = this.wallet.account;
    assert.isObject(oldDetails, 'oldDetails');
    assert.isObject(newDetails, 'newDetails');
    const oldSocialHashes = constructSocials(oldDetails);
    const newSocialHashes = constructSocials(newDetails);
    if (newSocialHashes.length === 0) return Promise.resolve();
    console.log("updating on blockchain:", account, oldSocialHashes, newSocialHashes);
    return this.wallet.estimateAndSend(this.contract.address, this.contract.abi, 'updateSocials', [oldSocialHashes, newSocialHashes]);
  }

  _setBlockchainStat(stat, value) {
    this.blockchainStats[stat] = value;
    stateManager.dispatch('communityStats', {...this.blockchainStats});
    return value;
  }
}


function validateSocials(details) {
  const results = {};
  ['twitter', 'discord', 'telegram'].forEach(social => {
    const value = details[social] ? details[social].trim() : undefined;
    if (value && value.length > 0) results[social] = value;
  })
  return results;
}

function constructSocials(details) {
  const socialHashes = [];
  ['twitter', 'discord', 'telegram'].forEach(social => {
    const value = details[social];
    if (value && value.length > 0) socialHashes.push(keccak256(social+':'+value));
  })
  return socialHashes;
}