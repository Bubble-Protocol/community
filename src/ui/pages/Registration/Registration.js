// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import React, { useState } from "react";
import './style.css';
import communityImage from "../../images/community.png";
import { stateManager } from "../../../state-context";
import { useConnectModal, ConnectButton } from '@rainbow-me/rainbowkit';
import { SocialsForm } from "./components/SocialsForm";
import { CheckBox } from "../../components/CheckBox/CheckBox";


/**
 * @dev The main application screen
 */

export function Registration() {

  // RainbowKit hooks
  const { openConnectModal } = useConnectModal();

  // Model state data
  const appState = stateManager.useStateData('state')();
  const appError = stateManager.useStateData('error')();
  const isBanned = stateManager.useStateData('isBanned')();
  const { register } = stateManager.useStateData('community-functions')();
  const { memberCount } = stateManager.useStateData('community-stats')();
  
  // Local state data
  const [accepted, setAccepted] = useState(false);
  const [registering, setRegistering] = useState(false);
  const [registerError, setRegisterError] = useState(false);

  // Referral parameter
  const referral = new URLSearchParams(window.location.search).get('referral');

  function registerUser({ name, twitter, discord, telegram }) {
    setRegistering(true);
    register({ name, twitter, discord, telegram, referral })
      .catch(setRegisterError)
      .finally(() => setRegistering(false));
  }
  return (
    <div className="registration">
        <div className="hero-section">
            <div className="titles">
                <span className="title">
                  Welcome To The Bubble Community
                </span>
                <span className="subtitle">
                  Register to join our on-chain community and start collecting Bubble NFTs
                </span>
                {memberCount > 0 && <span className="member-count">{"Members: " + memberCount}</span>}
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

          {/* Banned View */}
          {appState === 'initialised' && isBanned &&
            <>
              <div className="notice">You have been banned from this community.</div>
              <p>
                If you think you have been banned in error, please contact the team on <a className="bold" href="https://discord.gg/sSnvK5C">discord</a> or <a className="bold" href="https://twitter.com/BubbleProtocol">twitter</a>.
              </p>
            </>
          }

          {/* Registration View */}
          {appState === 'initialised' && !isBanned &&
            <>
              <div className="section-paragraphs">
                <div className="disclaimer-box">
                  <CheckBox selected={accepted} setSelected={setAccepted} />
                  <div className="section-paragraphs">
                    <p>
                      By checking this box you agree to be an active participant in the Bubble Protocol community engagement programme. 
                    </p>
                    <p>
                      The Bubble Protocol community lets you turn your community engagements - such as likes, comments, discord activity, suggestions and development contributions - into points that will be converted to governance tokens once we launch our DAO.
                      <b><i> The more active you are the more points, and therefore governance tokens, you will earn! </i></b>
                      All points will be sent to your wallet address in the form of our <a className="community-link" href="https://polygonscan.com/token/0xEf9eD7fdAB95b8Bc02CFe05d869c3e08E7F102d1#balances" target="_blank">pre-goverance ERC20 token</a>.
                    </p>
                    <p>
                      Registration is performed on-chain on the Polygon network and requires a network fee.
                    </p>
                    <p className="disclaimer">
                      Your data is encrypted and stored securely in an off-chain bubble on the <a className="community-link" href="https://vault.bubbleprotocol.com/" target="_blank">Bubble Private Cloud</a>. 
                      You have full control of your data and can delete it at any time.  
                      Bubble Protocol can read the data from your bubble for the purposes of implementing its rewards program and other community promotions.
                      Your data will never be shared with anyone and will never be stored outside of your bubble.
                      For more information see our <a className="community-link" href="https://seedling-d.app/article/0x543686de00b1202dc94b34f9b05816c878e0766427e0f2d86ce916331880e756" target="_blank">privacy policy</a>.
                    </p>
                  </div>
                </div>
              </div>
              <SocialsForm buttonText="Register" onRegister={registerUser} registering={registering} disabled={!accepted} />
              {referral && <p className="center">Referred By: {referral}</p>}
            </>
          }

          {/* Error log */}
          {appError && <span className='error-text center'>Error!<br/>{formatError(appError)}</span>}
          {registerError && <span className='error-text center'>Registration Failed!<br/>{formatError(registerError)}</span>}

        </div>

    </div>
  );

}


function formatError(error) {
  if (error.code === 'username-registered') return "One of your usernames has already been registered to a different user";
  return error.details || error.message || error;
}

