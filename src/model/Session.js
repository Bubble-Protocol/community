// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import { assert } from '@bubble-protocol/core';
import { ecdsa } from '@bubble-protocol/crypto';
import { Key } from '@bubble-protocol/crypto/src/ecdsa';
import { stateManager } from '../state-context';
import { MemberBubble } from './bubbles/MemberBubble';
import { MemberAdminBubble } from './bubbles/MemberAdminBubble';
import { Delegation } from '@bubble-protocol/client';

/**
 * @dev Application state enum. @See the `state` property below.
 */
const STATES = {
  open: 'open',
  loggedIn: 'logged-in'
}

/**
 * A Session is an instance of the app with a locally saved state. The local device can support
 * multiple sessions allowing the user to have different accounts for different wallet accounts.
 * 
 * The Session is identified by its ID, passed in the constructor. The state is saved to 
 * localStorage with the Session ID as the key name.
 * 
 * The Session is responsible for initialising any account data, including deploying any smart 
 * contracts and constructing any bubbles if they haven't been created before.
 */
export class Session {

  state = STATES.open;
  id;
  account;
  wallet;
  community;
  bubbleConfig;
  memberData;

  /**
   * @dev True if this account is a member of the community
   */
  isMember = false;
  isBanned = false;
  isMemberAdmin = false;
  isNftAdmin = false;

  /**
   * @dev The session private key, held in local storage and read on construction.
   */
  loginKey;

  /**
   * @dev Constructs this Session from the locally saved state.
   */
  constructor(config, account, wallet, community, token) {
    console.trace('Constructing session');
    assert.isString(config.appId, 'config.appId');
    assert.isObject(config.community, 'config.contract');
    assert.isObject(config.community.contract, 'config.contract');
    assert.isNumber(config.community.contract.chain, 'config.contract.chain');
    ecdsa.assert.isAddress(config.community.contract.address, 'config.contract.address');
    assert.isObject(config.community.bubble, 'config.bubble');
    assert.isString(config.community.bubble.provider, 'config.bubble.provider');
    assert.isHexString(config.community.bubble.adminPublicKey, 'config.bubble.adminPublicKey');
    ecdsa.assert.isAddress(account, 'account');
    assert.isObject(wallet, 'wallet');
    assert.isObject(community, 'community');
    assert.isObject(token, 'token');
    this.id = config.appId+'-'+config.community.contract.chain+'-'+account.slice(2).toLowerCase();
    console.trace('session id:', this.id);
    this.account = account;
    this.wallet = wallet;
    this.community = community;
    this.preGovToken = token;
    this.bubbleConfig = {
      adminPublicKey: config.community.bubble.adminPublicKey,
      bubbleId: {
        chain: config.community.contract.chain,
        contract: config.community.contract.address,
        provider: config.community.bubble.provider
      }
    }
    this._loadState();
  }

  /**
   * @dev Initialises the Session. The state of construction is determined by the properties read  
   * from the local saved state during construction.
   */
  async initialise() {
    console.trace('Initialising session');
    stateManager.dispatch('isMember', false);
    await this._checkAccountIsMemberAdmin();
    await this._checkAccountIsMember();
    if (!this.isMember) this._checkAccountIsBanned();
    await this._refreshMemberState();
    console.trace('Session initialised');
  }

  /**
   * @dev Logs in by requesting a login message signature from the user's wallet.
   * If `rememberMe` is set, the login will be saved indefinitely, or until `logout` is called.
   */
  async login(rememberMe = false) {
    if (this.state === STATES.loggedIn) return Promise.resolve();
    return this.wallet.login(this.account)
    .then(signature => {
      this.loginKey = new Key(ecdsa.hash(signature));
      if (rememberMe) this._saveState();
      else this._calculateState();
      return this._refreshMemberState();
    })
  }

  /**
   * @dev Logs out of the session, deleting any saved login details
   */
  logout() {
    this.loginKey = undefined;
    this.memberData = undefined;
    this.memberBubble = undefined;
    this._saveState();
  }

  /**
   * @dev Register a new member both on the blockchain and in the bubble
   */
  async register(details) {
    if (this.state !== STATES.loggedIn) return Promise.reject("Log in before registering");
    this.memberData = details;
    this._saveState();
    return this.community.register(this.loginKey.address, details)
      .then(validatedDetails => details = {...details, ...validatedDetails})
      .then(this._checkAccountIsMember.bind(this))
      .then(this._refreshMemberState.bind(this))
      .then(() => {
        if (this.isMember && this.memberBubble) return this.memberBubble.setData(details);
      });
  }

  /**
   * @dev Deregister both on the blockchain and from the bubble
   */
  async deregister() {
    if (this.state !== STATES.loggedIn) return Promise.reject("Log in before deregistering");
    await this.memberBubble.deleteData();
    await this.community.deregister(this.account);
    this.isMember = false;
    stateManager.dispatch('isMember', false);
    this.logout();
  }

  /**
   * @dev Update member data both on the blockchain and in the bubble
   */
  async updateMemberData(newData) {
    if (!this.isMember) return Promise.reject('not a member');
    if (!this.memberBubble) return Promise.reject('internal error: member bubble has not yet been constructed');
    console.log("updating member details:", newData);
    await this.community.updateSocials(newData);
    await this.memberBubble.setData(newData);
    this.memberData = this.memberBubble.memberData;
    this._saveState();
    stateManager.dispatch('member-data', this.memberBubble.memberData);
  }

  /**
   * @dev Deregister, from the blockchain and delete all data from the bubble
   */
  async deregisterMember(account) {
    if (!this.isMemberAdmin) return Promise.reject('not an admin member');
    if (!this.memberAdminBubble) return Promise.reject('internal error: member admin bubble has not yet been constructed');
    return this.community.deregisterMember(account)
    .then(() => this.memberAdminBubble.deleteMemberFile(account));
  }

  /**
   * @dev Ban, from the blockchain and delete all data from the bubble
   */
  async banMember(account) {
    if (!this.isMemberAdmin) return Promise.reject('not an admin member');
    if (!this.memberAdminBubble) return Promise.reject('internal error: member admin bubble has not yet been constructed');
    return this.community.banMember(account)
    .then(() => this.memberAdminBubble.deleteMemberFile(account));
  }

  /**
   * @dev Refreshes the `isMember` state for the current wallet account
   */
  async _checkAccountIsMember() {
    this.isMember = await this.community.isMember(this.wallet.account)
    stateManager.dispatch('isMember', this.isMember);
  }

  /**
   * @dev Refreshes the `isBanned` state for the current wallet account
   */
  async _checkAccountIsBanned() {
    this.isBanned = await this.community.isBanned(this.wallet.account)
    stateManager.dispatch('isBanned', this.isBanned);
  }

  /**
   * @dev Refreshes the `isMember` state for the current wallet account
   */
  async _checkAccountIsMemberAdmin() {
    this.isMemberAdmin = await this.community.isMemberAdmin(this.wallet.account)
    console.debug('isMemberAdmin', this.isMemberAdmin);
    stateManager.dispatch('isMemberAdmin', this.isMemberAdmin);
  }

  /**
   * @dev If a member and logged in, constructs the member bubble and fetches other 
   * member metadata
   */
  async _refreshMemberState() {
    if (this.isMemberAdmin && !this.adminDelegation && this.state === STATES.loggedIn) await this._obtainAdminDelegation ();
    const promises = [];
    if (this.isMember && !this.memberBubble && this.state === STATES.loggedIn) {
      promises.push(this._getMemberPoints());
      promises.push(this._constructMemberBubble());
    }
    if (this.isMemberAdmin && !this.memberAdminBubble && this.state === STATES.loggedIn) {
      promises.push(this._constructMemberAdminBubble());
    }
    return Promise.all(promises);
  }

  /**
   * @dev Constructs the member bubble, reading the member data from the bubble.
   * Saves a local copy of the member data in case of access problems.
   */
  async _constructMemberBubble() {
    this.memberBubble = new MemberBubble(this.bubbleConfig, this.account, this.loginKey);
    await this.memberBubble.initialise();
    if (!this.memberBubble.memberData && this.memberData) await this.memberBubble.setData(this.memberData);
    else {
      this.memberData = this.memberBubble.memberData;
      this._saveState();
    }
    stateManager.dispatch('member-data', this.memberBubble.memberData);
  }

  /**
   * @dev Constructs the member admin bubble
   */
  async _constructMemberAdminBubble() {
    this.memberAdminBubble = new MemberAdminBubble(this.bubbleConfig, this.account, this.loginKey, this.adminDelegation);
    // await this.memberAdminBubble.create('<MEMBER_ADMIN_KEY>');  // remove leading '0x'
    await this.memberAdminBubble.initialise();
    // await this.memberAdminBubble.addAdminMember('<PUBLIC_KEY>');
  }

  /**
   * @dev Requests the user to sign the admin delegation
   */
  async _obtainAdminDelegation() {
    const delegation = new Delegation(this.loginKey.address, 'never');
    delegation.permitAccessToBubble({...this.bubbleConfig.bubbleId, provider: this.bubbleConfig.bubbleId.provider.split('/')[2]});
    await delegation.sign(this.wallet.getSignFunction());
    this.adminDelegation = delegation;
    this._saveState();
  }

  /**
   * @dev gets the number of pre-governance tokens owned by this account
   */
  async _getMemberPoints() {
    const points = await this.preGovToken.balanceOf(this.account);
    stateManager.dispatch('member-points', points);
    return points;
  }
  
  /**
   * @dev Loads the Session state from localStorage
   */
  _loadState() {
    const stateJSON = window.localStorage.getItem(this.id);
    const stateData = stateJSON ? JSON.parse(stateJSON) : {};
    console.trace('loaded session state', stateData);
    try {
      this.loginKey = stateData.key ? new Key(stateData.key) : undefined;
    }
    catch(_){}
    this.memberData = stateData.memberData || {};
    this.adminDelegation = stateData.adminDelegation;
    this._calculateState();
  }

  /**
   * @dev Saves the Session state to localStorage
   */
  _saveState() {
    console.trace('saving session state');
    const stateData = {
      key: this.loginKey ? this.loginKey.privateKey : undefined,
      memberData: this.memberData,
      adminDelegation: this.adminDelegation
    };
    window.localStorage.setItem(this.id, JSON.stringify(stateData));
    this._calculateState();
  }

  /**
   * @dev Determines the value of this.state
   */
  _calculateState() {
    const oldState = this.state;
    this.state = this.loginKey ? STATES.loggedIn : STATES.open;
    if (this.state !== oldState) {
      console.trace("session state:", this.state);
      stateManager.dispatch('session-state', this.state);
    }
  }

}