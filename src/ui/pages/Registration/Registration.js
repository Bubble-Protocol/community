// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import React, { useState } from "react";
import './style.css';
import communityImage from "../../images/community.png";
import { stateManager } from "../../../state-context";
import { useConnectModal, ConnectButton } from '@rainbow-me/rainbowkit';
import { TextBox } from "../../components/TextBox/TextBox";


/**
 * @dev The main application screen
 */

export function Registration() {

  // RainbowKit hooks
  const { openConnectModal } = useConnectModal();

  // Model state data
  const appState = stateManager.useStateData('state')();
  const appError = stateManager.useStateData('error')();
  const { register } = stateManager.useStateData('communityFunctions')();
  
  // Local state data
  const [registering, setRegistering] = useState(false);
  const [registerError, setRegisterError] = useState(false);
  const [name, setName] = useState('');
  const [twitter, setTwitter] = useState('');
  const [discord, setDiscord] = useState('');
  const [telegram, setTelegram] = useState('');

  function registerUser() {
    setRegistering(true);
    register({ name, twitter, discord, telegram })
      .catch(setRegisterError)
      .finally(() => setRegistering(false));
  }

  const usernamesValid = 
    twitter.length > 0 &&
    discord.length > 0 &&
    telegram.length > 0;

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
              <div className="form">
                <div className="row">
                  <div className="label">Name</div>
                  <TextBox text={name} onChange={setName} />
                </div>
                <div className="dividing-line"></div>
                <div className="social-row">
                  <div className="row border-top">
                    <div className="social-title">Twitter<span className="red"> *</span></div>
                    <a className="social-link" href="https://twitter.com/BubbleProtocol" target="_blank">Follow Us</a>
                  </div>
                  <div className="row">
                    <div className="label">Username</div>
                    <TextBox text={twitter} onChange={setTwitter} />
                  </div>
                </div>
                <div className="dividing-line"></div>
                <div className="social-row">
                  <div className="row border-top">
                    <div className="social-title">Discord<span className="red"> *</span></div>
                    <a className="social-link" href="https://discord.gg/sSnvK5C" target="_blank">Join Our Discord Server</a>
                  </div>
                  <div className="row">
                    <div className="label">Username</div>
                    <TextBox text={discord} onChange={setDiscord} />
                  </div>
                </div>
                <div className="dividing-line"></div>
                <div className="social-row">
                  <div className="row border-top">
                    <div className="social-title">Telegram<span className="red"> *</span></div>
                    <a className="social-link" href="https://t.me/+hzBnwu75AlMyNjBk" target="_blank">Join Our Telegram Server</a>
                  </div>
                  <div className="row">
                    <div className="label">Username</div>
                    <TextBox text={telegram} onChange={setTelegram} />
                  </div>
                </div>
                <div className="dividing-line"></div>
              </div>
              <p className="center">Please check the usernames above carefully before registering. If any of the details are incorrect you may not get credit for your earnings.</p>
              <div className="center"><ConnectButton /></div>
              <div className="button-row center">
                {!registering && <div className={"cta-button-solid" + (usernamesValid ? '' : " disabled")} onClick={usernamesValid ? registerUser : null}>Register</div>}
                {registering && <div className="loader small"></div>}
              </div>
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

