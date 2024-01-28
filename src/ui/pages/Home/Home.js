// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import React from "react";
import './style.css';
import communityImage from "../../images/community.png";
import { stateManager } from "../../../state-context";
import { useConnectModal } from '@rainbow-me/rainbowkit';


/**
 * @dev The community join screen
 */

export function Home() {

  // RainbowKit hooks
  const { openConnectModal } = useConnectModal();

  // Model state data
  const appState = stateManager.useStateData('state')();
  const appError = stateManager.useStateData('error')();
  
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

          {/* Spinner View */}
          {appState === 'initialising' && <div className="loader"></div>}

          {/* Failure Views */}
          {appState === 'new' && <p>Unexpected app state 'New'</p>}
          {appState === 'failed' && <p>Failed to initialise app</p>}

          {/* Connect View */}
          {appState === 'closed' &&
            <>
              <p>Connect your wallet to join the Bubble Community...</p>
              <div className="button-row">
                <div className="cta-button-hollow" onClick={openConnectModal}>Connect Wallet</div>
              </div>
            </>
          }

          {/* Error log */}
          {appError && <span className='error-text'>{formatError(appError)}</span>}

        </div>

    </>
  );

}


function formatError(error) {
  return error.message || error;
}

