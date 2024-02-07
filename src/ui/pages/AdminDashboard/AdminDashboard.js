// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import React, { useState } from "react";
import './style.css';
import { stateManager } from "../../../state-context";
import { validateUsername } from "../../../common/utils/social-utils";
import { TextBox } from "../../components/TextBox/TextBox";
import { ecdsa } from "@bubble-protocol/crypto";
import { assert } from "@bubble-protocol/client";


export function AdminDashboard() {

  // Model state data
  const appError = stateManager.useStateData('error')();
  const { logout } = stateManager.useStateData('wallet-functions')();
  const { deregisterMember, banMember } = stateManager.useStateData('community-functions')();
  const { mint } = stateManager.useStateData('token-functions')();
  const { memberCount } = stateManager.useStateData('community-stats')();
  const members = stateManager.useStateData('all-members')();

  // Local state data
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState(false);
  const [selected, setSelected] = useState('members');
  const [account, setAccount] = useState('');
  const [twitter, setTwitter] = useState('');
  const [discord, setDiscord] = useState('');
  const [telegram, setTelegram] = useState('');
  const [mintAmount, setMintAmount] = useState('');
  const [selectedMember, setSelectedMember] = useState();

  function deregister() {
    setError(null);
    setBusy(true);
    deregisterMember(account)
    .catch(setError)
    .finally(() => setBusy(false));
  }

  function ban() {
    setError(null);
    setBusy(true);
    banMember(account)
    .catch(setError)
    .finally(() => setBusy(false));
  }

  function mintTokens() {
    setError(null);
    setBusy(true);
    mint(account, parseInt(mintAmount.trim()))
    .catch(setError)
    .finally(() => setBusy(false));
  }

  function setSelectedMemberTo(member) {
    setSelectedMember(member);
    setAccount(member.account);
    setTwitter(member.twitter);
    setDiscord(member.discord);
    setTelegram(member.telegram);
  }

  const accountValid = ecdsa.assert.isAddress(account);

  const usernamesValid = 
    validateUsername(twitter, "https://twitter.com") &&
    validateUsername(discord) &&
    validateUsername(telegram);

  return (
    <div className="admin-dashboard">

      <div className="page-width-section title-section">
        <span className="page-title">
          Bubble Community Admin
        </span>
        <span className="member-count">Members: {''+memberCount}</span>
      </div>

      <div className="page-width-section admin-section">

        <div className="menu">
          <div className={"menu-item" + (selected === 'members' ? ' selected' : '')} onClick={() => setSelected('members')}>All Members</div>
          <div className={"menu-item" + (selected === 'info' ? ' selected' : '')} onClick={() => setSelected('info')}>Member Info</div>
          <div className={"menu-item" + (selected === 'register' ? ' selected' : '')} onClick={() => setSelected('register')}>Register Member</div>
          <div className={"menu-item" + (selected === 'deregister' ? ' selected' : '')} onClick={() => setSelected('deregister')}>Deregister Member</div>
          <div className={"menu-item" + (selected === 'ban' ? ' selected' : '')} onClick={() => setSelected('ban')}>Ban Member</div>
          <div className={"menu-item" + (selected === 'unban' ? ' selected' : '')} onClick={() => setSelected('unban')}>Unban Member</div>
          <div className={"menu-item" + (selected === 'mint' ? ' selected' : '')} onClick={() => setSelected('mint')}>Mint Tokens</div>
          <div className={"menu-item" + (selected === 'batch-mint' ? ' selected' : '')} onClick={() => setSelected('batch-mint')}>Batch Mint</div>
        </div>

        <div className="admin-contents">

          { selected === 'members' &&
            <>
              <span className="section-title">All Members</span>
              <div className="member-list">
                <div className="member header-row">
                  <div>Account</div>
                  <div>Twitter</div>
                  <div>Discord</div>
                  <div>Telegram</div>
                  <div>Name</div>
                </div>
                {members.map(m => 
                  <div className={"member" + (selectedMember === m ? ' selected' : '')} key={m.account} onClick={() => setSelectedMemberTo(m)}>
                    <div className="mono">{formatAccount(m.account)}</div>
                    <div>{m.twitter}</div>
                    <div>{m.discord}</div>
                    <div>{m.telegram}</div>
                    <div>{m.name}</div>
                  </div>
                )}
              </div>
            </>
          }

          { selected === 'info' &&
            <>
              <span className="section-title">Member Info</span>
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
              </div>
            </>
          }

          { selected === 'register' &&
            <>
              <span className="section-title">Register Member</span>
              <p>Action not yet supported.</p>
            </>
          }

          { selected === 'deregister' &&
            <>
              <span className="section-title">Deregister Member</span>
              <p>This will deregister the member from the community. Their tokens will still be theirs. They will be able to re-register.</p>
              <div className="form">
                <div className="row">
                  <div className="label">Account</div>
                  <TextBox text={account} onChange={setAccount} />
                </div>
                <div className="button-row center">
                  <div className={"cta-button-hollow" + (accountValid ? '' : " disabled")} onClick={accountValid ? deregister : null}>Deregister</div>
                </div>
              </div>
            </>
          }

          { selected === 'ban' &&
            <>
              <span className="section-title">Ban Member</span>
              <p>This will ban the member and their social usernames from the community. Their tokens will still be theirs. They will not be able to re-register using any of their social media usernames.</p>
              <div className="form">
                <div className="row">
                  <div className="label">Account</div>
                  <TextBox text={account} onChange={setAccount} />
                </div>
                <div className="button-row center">
                  <div className={"cta-button-hollow" + (accountValid ? '' : " disabled")} onClick={accountValid ? ban : null}>Ban</div>
                </div>
              </div>
            </>
          }

          { selected === 'unban' &&
            <>
              <span className="section-title">Unban Member</span>
              <p>Action not yet supported.</p>
            </>
          }

          { selected === 'mint' &&
            <>
              <span className="section-title">Mint Tokens For Member</span>
              <div className="form">
                <div className="row">
                  <div className="label">Account</div>
                  <TextBox text={account} onChange={setAccount} />
                </div>
                <div className="row">
                  <div className="label">Amount</div>
                  <TextBox text={mintAmount} onChange={setMintAmount} />
                </div>
                <div className="button-row center">
                  <div className={"cta-button-hollow" + (accountValid && isInteger(mintAmount) ? '' : " disabled")} onClick={accountValid && isInteger(mintAmount) ? mintTokens : null}>Mint</div>
                </div>
              </div>
            </>
          }

          { selected === 'batch-mint' &&
            <>
              <span className="section-title">Mint Tokens For Multiple Members</span>
              <p>Action not yet supported.</p>
            </>
          }

          {busy && <div className="loader small"></div>}

          {/* Error log */}
          {appError && <span className='error-text center'>Error!<br/>{formatError(appError)}</span>}
          {error && <span className='error-text center'>Failed - {formatError(error)}</span>}

        </div>

      </div>

      <div className="page-width-section">
        {!busy && <div className="section-link" onClick={logout}>Logout</div>}
      </div>

    </div>
  );

}


function formatError(error) {
  if (error.code === 'username-registered') return "One of your usernames has already been registered to a different user";
  return error.details || error.message || error;
}

function formatAccount(acc) {
  return acc.slice(0,6) + '..' + acc.slice(-4);
}

function isInteger(str) {
  return str.trim().match(/^[0-9]+$/)
}