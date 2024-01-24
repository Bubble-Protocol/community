// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import { ecdsa } from '@bubble-protocol/crypto';
import { ContentId, assert } from '@bubble-protocol/core';

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

  /**
   * @dev The session private key, held in local storage and read on construction.
   */
  key;

  /**
   * @dev Constructs this Session from the locally saved state.
   */
  constructor(id, chain, bubbleProvider, wallet) {
    console.trace('Constructing session', id);
    assert.isString(id, 'id');
    assert.isObject(chain, 'chain');
    assert.isNumber(chain.id, 'chain.id');
    assert.isString(bubbleProvider, 'bubbleProvider');
    assert.isObject(wallet, 'wallet');
    this.id = id;
    this.chain = chain;
    this.bubbleProvider = bubbleProvider;
    this.wallet = wallet;
    this._loadState();
  }

  /**
   * @dev Initialises the Session. The state of construction is determined by the properties read  
   * from the local saved state during construction.
   * 
   * i.e.: 
   * 
   *   this.key = null   ->  New, so construct application key
   */
  async initialise() {

    console.trace('Initialising session');

    if (!this.key) {
      // brand new session
      console.trace('creating session key');
      this.key = new ecdsa.Key();
      this._saveState();
    }

  }

  /**
   * @dev Returns `true` if the session has not been fully initialised
   */
  isNew() {
    return this.key === undefined;
  }

  /**
   * @dev Loads the Session state from localStorage
   */
  _loadState() {
    const stateJSON = window.localStorage.getItem(this.id);
    const stateData = stateJSON ? JSON.parse(stateJSON) : {};
    console.trace('loaded state', stateData);
    this.key = stateData.key;
  }

  /**
   * @dev Saves the Session state to localStorage
   */
  _saveState() {
    const stateData = {
      key: this.key.privateKey
    };
    window.localStorage.setItem(this.id, JSON.stringify(stateData));
  }

}