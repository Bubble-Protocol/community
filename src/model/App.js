// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import { stateManager } from '../state-context';
import { DEFAULT_CONFIG } from './config';
import { Wallet } from './Wallet';
import { Session } from './Session';
import { polygon } from 'wagmi/chains';
import { Community } from './Community';
import { PreGovernanceToken } from './PreGovernanceToken';

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
   * @dev Interface to the BubblePreGovernanceToken smart contract.
   */
  token;

  /**
   * @dev Constructs the RainbowKit wallet handler and sets up the initial UI state.
   */
  constructor() {
    // Construct the wallet and listen for changes to the selected account
    this.wallet = new Wallet("Bubble Protocol Community");
    this.wallet.on('account-changed', this._accountChanged.bind(this));

    // Construct the Community
    this.community = new Community(DEFAULT_CONFIG.community, this.wallet);

    // Construct the Pre-Governance Token
    this.token = new PreGovernanceToken(DEFAULT_CONFIG.preGovToken, this.wallet);

    // Register UI state data
    stateManager.register('state', this.state);
    stateManager.register('error');
    stateManager.register('session-state', 'closed');
    stateManager.register('isMember', false);
    stateManager.register('isBanned', false);
    stateManager.register('isMemberAdmin', false);
    stateManager.register('member-data', {});
    stateManager.register('member-points', 0);
    stateManager.register('all-members', []);

    // Register UI functions
    stateManager.register('wallet-functions', {
      login: this.login.bind(this),
      logout: this.logout.bind(this)
    });
    stateManager.register('community-functions', {
      register: this.register.bind(this),
      deregister: this.deregister.bind(this),
      deregisterMember: this.deregisterMember.bind(this),
      banMember: this.banMember.bind(this),
      updateData: this.updateMemberData.bind(this)
    });
    stateManager.register('token-functions', {
      mint: this.mintTokens.bind(this),
      batchMint: this.batchMintTokens.bind(this)
    });
  }

  /**
   * @dev Logs in to the connected session. Rejects if wallet is not connected.
   */
  async login(...args) {
    if (!this.session) return Promise.reject('Connect wallet before logging in');
    return this.session.login(...args)
    .catch(error => {
      if (error && error.code === 'missing-admin-file') {
        this._setState(STATES.failed);
        stateManager.dispatch('error', error)
      }
      else throw(error);
    })
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
    if (!this.session) return Promise.reject("internal error: session is missing");
    return this.session.register(details);
  }

  /**
   * @dev Deregister, from the blockchain and delete all data from the bubble
   */
  async deregister() {
    if (!this.state == STATES.loggedIn) return Promise.reject("Log in before deregistering");
    if (!this.session) return Promise.reject("internal error: session is missing");
    return this.session.deregister();
  }

  /**
   * @dev Deregister, from the blockchain and delete all data from the bubble
   */
  async deregisterMember(account) {
    if (!this.state == STATES.loggedIn) return Promise.reject("Log in before updating");
    if (!this.session) return Promise.reject("internal error: session is missing");
    return this.session.deregisterMember(account);
  }

  /**
   * @dev Ban, from the blockchain and delete all data from the bubble
   */
  async banMember(account) {
    if (!this.state == STATES.loggedIn) return Promise.reject("Log in before updating");
    if (!this.session) return Promise.reject("internal error: session is missing");
    return this.session.banMember(account);
  }

  /**
   * @dev Update member's data to both blockchain and bubble
   */
  async updateMemberData(details) {
    if (!this.state == STATES.loggedIn) return Promise.reject("Log in before updating");
    if (!this.session) return Promise.reject("internal error: session is missing");
    return this.session.updateMemberData(details);
  }

  /**
   * @dev mint a given number of tokens for a given member
   */
  async mintTokens(account, amount) {
    if (!this.state == STATES.loggedIn) return Promise.reject("Log in before updating");
    return this.token.mint(account, amount);
  }

  /**
   * @dev mint tokens for multiple members
   */
  async batchMintTokens(batch) {
    if (!this.state == STATES.loggedIn) return Promise.reject("Log in before updating");
    return this.token.batchMint(batch);
  }

  /**
   * @dev Called by the wallet whenever the user switches accounts or disconnects their wallet.
   */
  _accountChanged(account) {
    this._closeSession();
    if (account) {
      this.community.initialise();
      this._openSession(account);
    }
    else this._setState(STATES.closed);
  }

  /**
   * @dev Starts a new session on first connect or whenever the wallet account is changed. Closes
   * any existing session first, clearing the UI state.
   */
  _openSession(account) {
    this.session = new Session(DEFAULT_CONFIG, account, this.wallet, this.community, this.token);
    this._initialiseSession();
  }

  /**
   * @dev Initialises the Session. Keeps the UI up-to-date on the state of the app as the 
   * Session is initialised.
   */
  async _initialiseSession() {
    this._setState(STATES.initialising);
    return this.session.initialise()
      .then(() => {
        this._setState(STATES.initialised);
      })
      .catch(error => {
        console.warn(error);
        this._setState(STATES.failed);
        stateManager.dispatch('error', error)
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