// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import React, { useState } from "react";
import './style.css';
import communityImage from "../../images/community.png";
import { stateManager } from "../../../state-context";
import { useConnectModal, ConnectButton } from '@rainbow-me/rainbowkit';
import { SocialsForm } from "./components/SocialsForm";


/**
 * @dev The main application screen
 */

export function Registration() {

  // RainbowKit hooks
  const { openConnectModal } = useConnectModal();

  // Model state data
  const appState = stateManager.useStateData('state')();
  const appError = stateManager.useStateData('error')();
  const { register } = stateManager.useStateData('community-functions')();
  
  // Local state data
  const [registering, setRegistering] = useState(false);
  const [registerError, setRegisterError] = useState(false);

  function registerUser({ name, twitter, discord, telegram }) {
    setRegistering(true);
    register({ name, twitter, discord, telegram })
      .catch(setRegisterError)
      .finally(() => setRegistering(false));
  }

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
          <span className="section-title">Register</span>

          {/* Spinner View */}
          {appState === 'initialising' && <div className="loader"></div>}

          {/* Failure Views */}
          {appState === 'new' && <p>Unexpected app state 'New'</p>}
          {appState === 'failed' && <p>Unexpected app state 'Failed'</p>}

          {/* Connect View */}
          {appState === 'closed' &&
            <>
              <p>To register with the Bubble Protocol community you first need to connect your wallet.</p>
              <div className="button-row">
                <div className="cta-button-hollow" onClick={openConnectModal}>Connect Wallet</div>
              </div>
            </>
          }

          {/* Registration View */}
          {appState === 'initialised' &&
            <>
              <div className="section-paragraphs">
                <p>
                  Register to join the Bubble Community. 
                  Any rewards or NFTs you earn through your social media activities will be sent to your wallet address.
                  Registration is performed on-chain on the Polygon network and requires a network fee.
                </p>
                <p className="disclaimer">
                  Your data is encrypted and stored securely in an off-chain bubble on the Bubble Private Cloud. 
                  You have full control of your data and can delete it at any time.  
                  Bubble Protocol has read access to your data for the purposes of implementing its referral program and other community promotions.
                  Your data will never be shared with anyone.
                </p>
              </div>
              <SocialsForm buttonText="Register" onRegister={registerUser} registering={registering} />
            </>
          }

          {/* Error log */}
          {appError && <span className='error-text center'>Error!<br/>{formatError(appError)}</span>}
          {registerError && <span className='error-text center'>Registration Failed!<br/>{formatError(registerError)}</span>}

        </div>

    </>
  );

}


function formatError(error) {
  if (error.code === 'username-registered') return "One of your usernames has already been registered";
  return error.details || error.message || error;
}

