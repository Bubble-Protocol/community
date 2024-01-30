// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import { stateManager } from '../state-context';
import { DEFAULT_CONFIG } from './config';
import { Wallet } from './Wallet';
import { Session } from './Session';
import { polygon } from 'wagmi/chains';
import { Community } from './Community';

/**
 * @dev ID used to prefix all local storage entries
 */
const APP_ID = 'bubble-community';

/**
 * @dev Blockchain ID
 */
const CHAIN = polygon;

/**
 * @dev Remote bubble server that hosts all community bubbles
 */
const BUBBLE_PROVIDER = "https://vault.bubbleprotocol.com/v2/polygon";

/**
 * @dev Application state enum. @See the `state` property below.
 */
const STATES = {
  closed: 'closed',
  initialising: 'initialising',
  initialised: 'initialised',
  failed: 'failed'
}


/**
 * The CommunityApp class is the entry point for the model. It provides all UI-facing functions
 * and keeps the UI informed of the application state, task list and any errors via the 
 * `stateManager`.
 */
export class CommunityApp {

  /**
   * @dev Combined initialisation state of the application and session made available to the UI.
   * 
   *   - closed => wallet not connected
   *   - new => wallet connected but no task list bubble exists. Task list needs creating
   *   - initialising => task list is being initialised (bubble being created or list being loaded)
   *   - initialised => task list has been successfully initialised (available in the `tasks` event)
   *   - failed => task list failed to initialise (cause given in the `error` event)
   */
  state = STATES.closed;

  /**
   * @dev The current 'logged in' session. When the user connects their wallet or switches
   * wallet account a new session is constructed. (@see _accountChanged).
   */
  session;

  /**
   * @dev The wallet handler that listens to the user's wallet state (via wagmi).
   */
  wallet;

  /**
   * @dev Interface to the BubbleCommunity smart contract.
   */
  community;

  /**
   * @dev Constructs the RainbowKit wallet handler and sets up the initial UI state.
   */
  constructor() {
    // Construct the wallet and listen for changes to the selected account
    this.wallet = new Wallet("Bubble Protocol Community");
    this.wallet.on('account-changed', this._accountChanged.bind(this));

    // Construct the Community
    this.community = new Community(DEFAULT_CONFIG.community, this.wallet);

    // Register UI state data
    stateManager.register('state', this.state);
    stateManager.register('session-state', 'closed');
    stateManager.register('isMember', false);
    stateManager.register('error');

    // Register UI functions
    stateManager.register('wallet-functions', {
      login: this.login.bind(this),
      logout: this.logout.bind(this)
    });
    stateManager.register('community-functions', {
      register: this.register.bind(this)
    });
  }

  /**
   * @dev Logs in to the connected session. Rejects if wallet is not connected.
   */
  async login(...args) {
    if (!this.session) return Promise.reject('Connect wallet before logging in');
    return this.session.login(...args);
  }

  /**
   * @dev Logs out of the connected session. Rejects if wallet is not connected.
   */
  async logout() {
    if (!this.session) return Promise.reject('Connect wallet before logging out');
    return this.session.logout();
  }

  /**
   * @dev Register a new member
   */
  async register(details) {
    if (!this.state == STATES.loggedIn) return Promise.reject("Log in before registering");
    return this.community.register(details)
      .then(this._checkAccountIsMember.bind(this));
  }

  /**
   * @dev Called by the wallet whenever the user switches accounts or disconnects their wallet.
   */
  _accountChanged(account) {
    this._closeSession();
    if (account) this._openSession(account);
    else this._setState(STATES.closed);
  }

  /**
   * @dev Starts a new session on first connect or whenever the wallet account is changed. Closes
   * any existing session first, clearing the UI state.
   */
  _openSession(account) {
    this.session = new Session(APP_ID, account, CHAIN, BUBBLE_PROVIDER, this.wallet);
    this._initialiseSession();
  }

  /**
   * @dev Initialises the Session. Keeps the UI up-to-date on the state of the app as the 
   * Session is initialised.
   */
  async _initialiseSession() {
    this._setState(STATES.initialising);
    stateManager.dispatch('isMember', false);
    return this.session.initialise()
      .then(() => {
        this._checkAccountIsMember();
      })
      .catch(error => {
        console.warn(error);
        this._setState(STATES.failed);
        stateManager.dispatch('error', error)
      });
  }

  /**
   * @dev Refreshes the `isMember` state for the current wallet account
   */
  async _checkAccountIsMember() {
    return this.community.isMember(this.wallet.account)
    .then(result => {
      stateManager.dispatch('isMember', result);
      this._setState(STATES.initialised);
    });
  }

  /**
   * @dev Closes any existing session and clears the UI state
   */
  _closeSession() {
    if (this.session) {
      stateManager.dispatch('error');
      this.session = undefined;
      stateManager.dispatch('session-state', 'closed');
    }
  }

  /**
   * @dev Sets the app state and informs the UI
   */
  _setState(state) {
    this.state = state;
    stateManager.dispatch('state', this.state);
  }

}