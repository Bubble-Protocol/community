// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import React, { useState } from "react";
import PropTypes from "prop-types";
import './style.css';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { TextBox } from "../../../../components/TextBox/TextBox";
import { validateUsername } from "../../../../../common/utils/social-utils";
import { assert } from "@bubble-protocol/crypto/src/ecdsa";


/**
 * @dev The main application screen
 */

export function MemberForm({onBan, onDeregister, initialValues={}, hideButtons=false}) {

  // Local state data
  const [account, setAccount] = useState(initialValues.account || '');
  const [twitter, setTwitter] = useState(initialValues.twitter || '');
  const [discord, setDiscord] = useState(initialValues.discord || '');
  const [telegram, setTelegram] = useState(initialValues.telegram || '');

  function ban() {
    onBan({account, twitter, discord, telegram});
  }

  function deregister() {
    onDeregister({account, twitter, discord, telegram});
  }

  const usernamesValid = 
    validateUsername(twitter, "https://twitter.com") &&
    validateUsername(discord) &&
    validateUsername(telegram);

  const accountValid = assert.isAddress(account);
  return (
    <div className="form">
      <div className="row">
        <div className="label">Account</div>
        <TextBox text={account} onChange={setAccount} />
      </div>
      <div className="row">
        <div className="label">Twitter</div>
        <TextBox text={twitter} onChange={setTwitter} />
      </div>
      <div className="row">
        <div className="label">Discord</div>
        <TextBox text={discord} onChange={setDiscord} />
      </div>
      <div className="row">
        <div className="label">Telegram</div>
        <TextBox text={telegram} onChange={setTelegram} />
      </div>
      <p className="center">Usernames must be correct to successfully update member</p>
      {!hideButtons && 
        <>
          <div className="button-row center">
            <div className={"cta-button-hollow" + (accountValid ? '' : " disabled")} onClick={accountValid ? ban : null}>Ban</div>
            <div className={"cta-button-hollow" + (accountValid ? '' : " disabled")} onClick={accountValid ? deregister : null}>Deregister</div>
          </div>
        </>
      }
    </div>
  );

}


MemberForm.propTypes = {
  onBan: PropTypes.func.isRequired,
  onDeregister: PropTypes.func.isRequired,
  hideButtons: PropTypes.bool,
  initialValues: PropTypes.object
};

