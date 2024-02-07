// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import React, { useState } from "react";
import './style.css';
import communityImage from "../../images/community.png";
import { stateManager } from "../../../state-context";
import { ConnectButton, useConnectModal } from '@rainbow-me/rainbowkit';
import { CheckBox } from "../../components/CheckBox/CheckBox";


/**
 * @dev The community join screen
 */

export function Home() {

  // RainbowKit hooks
  const { openConnectModal } = useConnectModal();

  // Model state data
  const appState = stateManager.useStateData('state')();
  const sessionState = stateManager.useStateData('session-state')();
  const appError = stateManager.useStateData('error')();
  const { login } = stateManager.useStateData('wallet-functions')();

  // Local state data
  const [rememberMe, setRememberMe] = useState(false);

  const adminUserFileMissing = appError && appError.code === 'missing-admin-file';

  return (
    <>
        <div className="hero-section community-page">
            <div className="titles">
                <span className="title">
                  Welcome To The Bubble Community
                </span>
                <span className="subtitle">
                  Register to join our on-chain community and start collecting Bubble NFTs
                </span>
            </div>
            <div className="hero-image-frame">
                <img className="hero-image community-page" src={communityImage} alt="hero"/>
                <img className="bubble2" src="/images/bubble2.png" alt="bubble"/>
                <img className="bubble3" src="/images/bubble1.png" alt="bubble"/>
                <img className="bubble1" src="/images/bubble3.png" alt="bubble"/>
            </div>
        </div>

        <div className="page-width-section">
          <span className="section-title">Join The Community</span>

          {appState !== 'closed' && appState !== 'initialising' && <ConnectButton /> }

          {/* Spinner View */}
          {appState === 'initialising' && <div className="loader"></div>}

          {/* Failure Views */}
          {appState === 'new' && <p>Unexpected app state 'New'</p>}
          {appState === 'failed' && !adminUserFileMissing && <p>Failed to initialise app</p>}
          {appState === 'initialised' && sessionState === 'logged-in' && <p>Unexpected initialised STATES</p>}

          {/* Connect View */}
          {appState === 'closed' &&
            <>
              <p>Connect your wallet to join the Bubble Community...</p>
              <div className="button-row">
                <div className="cta-button-hollow" onClick={openConnectModal}>Connect Wallet</div>
              </div>
            </>
          }

          {/* Login View */}
          {appState === 'initialised' && sessionState !== 'logged-in' &&
            <div className="button-row">
              <div className="cta-button-solid" onClick={() => login(rememberMe)}>Login</div>
              <div className="selector">
                <CheckBox selected={rememberMe} setSelected={setRememberMe} />
                <span>Remember Me</span>
              </div>
            </div>
          }

          {/* Error log */}
          {appError && !adminUserFileMissing && <span className='error-text'>{formatError(appError)}</span>}
          {adminUserFileMissing && <span>To complete your administrator setup, please send the following code to the community administrator:<br/><br/>{appError.publicKey}</span>}

        </div>

    </>
  );

}


function formatError(error) {
  return error.message || error;
}

