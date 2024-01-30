// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import { assert } from '@bubble-protocol/core';
import { ecdsa } from '@bubble-protocol/crypto';
import { Key } from '@bubble-protocol/crypto/src/ecdsa';
import { stateManager } from '../state-context';

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

  /**
   * @dev The session private key, held in local storage and read on construction.
   */
  key;

  /**
   * @dev Constructs this Session from the locally saved state.
   */
  constructor(appId, account, chain, bubbleProvider, wallet) {
    console.trace('Constructing session');
    assert.isString(appId, 'appId');
    ecdsa.assert.isAddress(account, 'account');
    assert.isObject(chain, 'chain');
    assert.isNumber(chain.id, 'chain.id');
    assert.isString(bubbleProvider, 'bubbleProvider');
    assert.isObject(wallet, 'wallet');
    this.id = appId+'-'+chain.id+'-'+account.slice(2).toLowerCase();
    console.trace('session id:', this.id);
    this.account = account;
    this.chain = chain;
    this.bubbleProvider = bubbleProvider;
    this.wallet = wallet;
    this._loadState();
  }

  /**
   * @dev Initialises the Session. The state of construction is determined by the properties read  
   * from the local saved state during construction.
   */
  async initialise() {

    console.trace('Initialising session');
    // Add custom code here
    console.trace('Session initialised');
  }

  /**
   * @dev Logs in by requesting a login message signature from the user's wallet.
   * If `rememberMe` is set, the login will be saved indefinitely, or until `logout` is called.
   */
  async login(rememberMe = false) {
    if (this.state === STATES.loggedIn) return Promise.resolve();
    this.wallet.login(this.account)
    .then(signature => {
      this.key = new Key(ecdsa.hash(signature));
      if (rememberMe) this._saveState();
      else this._calculateState();
    })
  }

  /**
   * @dev Logs out of the session, deleting any saved login details
   */
  logout() {
    this.key = undefined;
    this._saveState();
  }

  /**
   * @dev Loads the Session state from localStorage
   */
  _loadState() {
    const stateJSON = window.localStorage.getItem(this.id);
    const stateData = stateJSON ? JSON.parse(stateJSON) : {};
    console.trace('loaded session state', stateData);
    try {
      this.key = stateData.key ? new Key(stateData.key) : undefined;
    }
    catch(_){}
    this._calculateState();
  }

  /**
   * @dev Saves the Session state to localStorage
   */
  _saveState() {
    console.trace('saving session state');
    const stateData = {
      key: this.key.privateKey
    };
    window.localStorage.setItem(this.id, JSON.stringify(stateData));
    this._calculateState();
  }

  /**
   * @dev Determines the value of this.state
   */
  _calculateState() {
    const oldState = this.state;
    this.state = this.key ? STATES.loggedIn : STATES.open;
    if (this.state !== oldState) {
      console.trace("session state:", this.state);
      stateManager.dispatch('session-state', this.state);
    }
  }

}