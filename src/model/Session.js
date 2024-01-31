// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import { assert } from '@bubble-protocol/core';
import { ecdsa } from '@bubble-protocol/crypto';
import { Key } from '@bubble-protocol/crypto/src/ecdsa';
import { stateManager } from '../state-context';
import { MemberBubble } from './bubbles/MemberBubble';

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
  isMemberAdmin = false;
  isNftAdmin = false;

  /**
   * @dev The session private key, held in local storage and read on construction.
   */
  loginKey;

  /**
   * @dev Constructs this Session from the locally saved state.
   */
  constructor(config, account, wallet, community) {
    console.trace('Constructing session');
    assert.isString(config.appId, 'config.appId');
    assert.isObject(config.contract, 'config.contract');
    assert.isNumber(config.contract.chain, 'config.contract.chain');
    ecdsa.assert.isAddress(config.contract.address, 'config.contract.address');
    assert.isObject(config.bubble, 'config.bubble');
    assert.isString(config.bubble.provider, 'config.bubble.provider');
    assert.isHexString(config.bubble.adminPublicKey, 'config.bubble.adminPublicKey');
    ecdsa.assert.isAddress(account, 'account');
    assert.isObject(wallet, 'wallet');
    assert.isObject(community, 'community');
    this.id = config.appId+'-'+config.contract.chain+'-'+account.slice(2).toLowerCase();
    console.trace('session id:', this.id);
    this.account = account;
    this.wallet = wallet;
    this.community = community;
    this.bubbleConfig = {
      adminPublicKey: config.bubble.adminPublicKey,
      bubbleId: {
        chain: config.contract.chain,
        contract: config.contract.address,
        provider: config.bubble.provider
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
    await this._checkAccountIsMember();
    await this._refreshBubbles();
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
      return this._refreshBubbles();
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
      .then(this._checkAccountIsMember.bind(this))
      .then(this._refreshBubbles.bind(this))
      .then(() => {
        if (this.isMember && this.memberBubble) return this.memberBubble.setData(details);
      });
  }

  /**
   * @dev Deregister both on the blockchain and from the bubble
   */
  async deregister(details, force) {
    if (this.state !== STATES.loggedIn) return Promise.reject("Log in before deregistering");
    await this.memberBubble.deleteData();
    await this.community.deregister(this.account, {...this.memberData, ...details}, force);
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
    let oldUsernames = {};
    let newUsernames = {};
    const oldData = this.memberData;
    Object.keys(newData).forEach(key => {
      if (newData[key] !== oldData[key]) { 
        oldUsernames[key] = oldData[key];
        newUsernames[key] = newData[key];
      }
    })
    console.log("updating member details:", oldUsernames, newUsernames);
    await this.community.updateSocials(oldUsernames, newUsernames);
    await this.memberBubble.setData({...oldData, ...newData});
    this.memberData = this.memberBubble.memberData;
    this._saveState();
    stateManager.dispatch('member-data', this.memberBubble.memberData);
  }

  /**
   * @dev Refreshes the `isMember` state for the current wallet account
   */
  async _checkAccountIsMember() {
    this.isMember = await this.community.isMember(this.wallet.account)
    stateManager.dispatch('isMember', this.isMember);
  }

  /**
   * @dev Constructs any bubbles that can now be constructed
   */
  async _refreshBubbles() {
    if (this.isMember && !this.memberBubble && this.state === STATES.loggedIn) {
      await this._constructMemberBubble();
    }
  }

  /**
   * @dev Constructs the member bubble, reading the member data from the bubble.
   * Saves a local copy of the member data in case of access problems.
   */
  async _constructMemberBubble() {
    if (!this.isMember) return Promise.reject('not a member');
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
    this._calculateState();
  }

  /**
   * @dev Saves the Session state to localStorage
   */
  _saveState() {
    console.trace('saving session state');
    const stateData = {
      key: this.loginKey ? this.loginKey.privateKey : undefined,
      memberData: this.memberData
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