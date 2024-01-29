// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import React, { useState } from "react";
import PropTypes from "prop-types";
import './style.css';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { TextBox } from "../../../../components/TextBox/TextBox";
import { validateUsername } from "../../../../../common/utils/social-utils";


/**
 * @dev The main application screen
 */

export function SocialsForm({buttonText, registering, onRegister, initialValues={}}) {

  // Local state data
  const [name, setName] = useState(initialValues.name || '');
  const [twitter, setTwitter] = useState(initialValues.twitter || '');
  const [discord, setDiscord] = useState(initialValues.discord || '');
  const [telegram, setTelegram] = useState(initialValues.telegram || '');

  function register() {
    onRegister({name, twitter, discord, telegram});
  }

  const usernamesValid = 
    validateUsername(twitter, "https://twitter.com") &&
    validateUsername(discord) &&
    validateUsername(telegram);

  return (
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
      <p className="center">Please check the usernames above carefully. If any of the details are incorrect you may not get credit for your earnings.</p>
      <div className="center"><ConnectButton /></div>
      <div className="button-row center">
        {!registering && <div className={"cta-button-solid" + (usernamesValid ? '' : " disabled")} onClick={usernamesValid ? register : null}>{buttonText}</div>}
        {registering && <div className="loader small"></div>}
      </div>
    </div>
  );

}


SocialsForm.propTypes = {
  buttonText: PropTypes.string.isRequired,
  onRegister: PropTypes.func.isRequired,
  registering: PropTypes.bool,
  initialValues: PropTypes.object
};

