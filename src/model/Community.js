import { assert } from "@bubble-protocol/client";
import { keccak256 } from "viem";
import { stateManager } from "../state-context";

const MEMBER_ADMIN_ROLE = '0x5160d718b3cafa04f8d51bbd7b6f2828ba2c83e2c57f3ca11850ce45d05be042';
const NULL_SOCIAL = '0x0000000000000000000000000000000000000000000000000000000000000000';
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

  async isBanned(account) {
    return this.wallet.call(this.contract.address, this.contract.abi, 'isBanned', [account]);
  }

  async isMemberAdmin(account) {
    return this.wallet.call(this.contract.address, this.contract.abi, 'hasRole', [MEMBER_ADMIN_ROLE, account]);
  }

  async register(loginAddress, details) {
    const account = this.wallet.account;
    console.log("registering user:", account, details);
    assert.isObject(details, 'details');
    const socialHashes = constructSocials(details);
    console.log("registering on blockchain:", account, socialHashes);
    return this.wallet.estimateAndSend(this.contract.address, this.contract.abi, 'registerAsMember', [loginAddress, socialHashes]);
  }

  async deregister(account) {
    const walletAccount = this.wallet.account;
    if (walletAccount.toLowerCase() !== account.toLowerCase()) return Promise.reject('wallet account does not match requested account');
    console.log("deregistering user:", account);
    return this.wallet.estimateAndSend(this.contract.address, this.contract.abi, 'deregisterAsMember', []);
  }

  async deregisterMember(account) {
    console.log("deregistering user:", account);
    return this.wallet.estimateAndSend(this.contract.address, this.contract.abi, 'deregisterMember', [account]);
  }

  async banMember(account) {
    console.log("banning user:", account);
    return this.wallet.estimateAndSend(this.contract.address, this.contract.abi, 'banMember', [account]);
  }

  async updateSocials(newDetails) {
    const account = this.wallet.account;
    assert.isObject(newDetails, 'newDetails');
    const newSocialHashes = constructSocials(newDetails);
    if (newSocialHashes.length === 0) return Promise.resolve();
    console.log("updating on blockchain:", account, newSocialHashes);
    return this.wallet.estimateAndSend(this.contract.address, this.contract.abi, 'updateSocials', [newSocialHashes]);
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
  const trimmedDetails = validateSocials(details);
  if (!trimmedDetails.twitter) throw new Error('missing twitter username');
  if (!trimmedDetails.discord) throw new Error('missing discord username');
  if (!trimmedDetails.telegram) throw new Error('missing telegram username');
  const socialHashes = [];
  ['twitter', 'discord', 'telegram'].forEach(social => {
    socialHashes.push(keccak256(process.env.REACT_APP_SOCIAL_ENCRYPTION_SALT+':'+social+':'+trimmedDetails[social]));
  })
  socialHashes.push(NULL_SOCIAL);
  socialHashes.push(NULL_SOCIAL);
  return socialHashes;
}