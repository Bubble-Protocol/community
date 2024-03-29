import { assert } from "@bubble-protocol/client";
import { keccak256 } from "viem";
import { stateManager } from "../state-context";
import { extractUsername } from "../common/utils/social-utils";
import { ecdsa } from "@bubble-protocol/crypto";

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
    this.nftContract = config.nftContract;
    stateManager.register('community-stats', {...this.blockchainStats});
    this.register = this.register.bind(this);
  }

  initialise() {
    this._getMemberCount();
  }

  async _getMemberCount() {
    return this.wallet.call(this.contract.address, this.contract.abi, 'getMemberCount')
    .then(count => this._setBlockchainStat('memberCount', count))
    .catch(console.warn);
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
    const {validatedDetails, socialHashes} = constructSocials(details);
    console.log("registering on blockchain:", account, socialHashes);
    return this.wallet.estimateAndSend(this.contract.address, this.contract.abi, 'registerAsMember', [loginAddress, socialHashes])
    .then(this._getMemberCount.bind(this))
    .then(() => { return validatedDetails });
  }

  async updateSocials(newDetails) {
    const account = this.wallet.account;
    assert.isObject(newDetails, 'newDetails');
    const {validatedDetails, socialHashes} = constructSocials(newDetails);
    if (socialHashes.length === 0) return Promise.resolve();
    console.log("updating on blockchain:", account, socialHashes);
    return this.wallet.estimateAndSend(this.contract.address, this.contract.abi, 'updateSocials', [socialHashes])
    .then(() => { return validatedDetails });
  }

  async deregister(account) {
    const walletAccount = this.wallet.account;
    if (walletAccount.toLowerCase() !== account.toLowerCase()) return Promise.reject('wallet account does not match requested account');
    console.log("deregistering user:", account);
    return this.wallet.estimateAndSend(this.contract.address, this.contract.abi, 'deregisterAsMember', [])
    .then(this._getMemberCount.bind(this));
  }

  async deregisterMember(account) {
    console.log("deregistering user:", account);
    return this.wallet.estimateAndSend(this.contract.address, this.contract.abi, 'deregisterMember', [account])
    .then(this._getMemberCount.bind(this));
  }

  async banMember(account) {
    console.log("banning user:", account);
    return this.wallet.estimateAndSend(this.contract.address, this.contract.abi, 'banMember', [account])
    .then(this._getMemberCount.bind(this));
  }

  async unbanSocials(socials) {
    assert.isArray(socials, 'socials');
    const newSocialHashes = constructUnbanSocials(socials);
    if (newSocialHashes.length === 0) return Promise.resolve();
    console.log("unbanning socials:", newSocialHashes);
    return this.wallet.estimateAndSend(this.contract.address, this.contract.abi, 'unbanSocials', [newSocialHashes]);
  }

  async hasNft(address, account) {
    ecdsa.assert.isAddress(address, 'address');
    ecdsa.assert.isAddress(account, 'account');
    console.log('checking balance of', account, 'with nft at', address);
    return this.wallet.call(address, this.nftContract.abi, 'balanceOf', [account])
    .then(balance => balance > 0)
  }

  async mintNft(address) {
    ecdsa.assert.isAddress(address, 'address');
    console.log('minting nft at address', address);
    return this.wallet.estimateAndSend(address, this.nftContract.abi, 'mint');
  }

  _setBlockchainStat(stat, value) {
    this.blockchainStats[stat] = value;
    stateManager.dispatch('community-stats', {...this.blockchainStats});
    return value;
  }
}


function validateSocials(details) {
  const results = {};
  const twitter = extractUsername(details.twitter, "https://twitter.com");
  const discord = extractUsername(details.discord);
  const telegram = extractUsername(details.telegram, "https://t.me");
  if (twitter) results.twitter = twitter;
  if (discord) results.discord = discord;
  if (telegram) results.telegram = telegram;
  return results;
}

function constructSocials(details) {
  const validatedDetails = validateSocials(details);
  if (!validatedDetails.twitter) throw new Error('missing twitter username');
  if (!validatedDetails.discord) throw new Error('missing discord username');
  if (!validatedDetails.telegram) throw new Error('missing telegram username');
  const socialHashes = [];
  ['twitter', 'discord', 'telegram'].forEach(social => {
    socialHashes.push(keccak256(process.env.REACT_APP_SOCIAL_ENCRYPTION_SALT+':'+social+':'+validatedDetails[social].toLowerCase()));
  })
  socialHashes.push(NULL_SOCIAL);
  socialHashes.push(NULL_SOCIAL);
  return {validatedDetails, socialHashes};
}

function constructUnbanSocials(details) {
  const validatedDetails = validateSocials(details);
  const socialHashes = [];
  ['twitter', 'discord', 'telegram'].forEach(social => {
    if (validatedDetails[social]) socialHashes.push(keccak256(process.env.REACT_APP_SOCIAL_ENCRYPTION_SALT+':'+social+':'+validatedDetails[social].toLowerCase()));
  })
  return socialHashes;
}
