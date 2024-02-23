// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import React, { useEffect, useRef, useState } from "react";
import './style.css';
import { SocialsForm } from "../Registration/components/SocialsForm";
import { stateManager } from "../../../state-context";
import rehideNftImage from "../../images/rehide-nft-image.png";

export function Dashboard() {

  // Model state data
  const appError = stateManager.useStateData('error')();
  const { logout } = stateManager.useStateData('wallet-functions')();
  const { updateData, deregister, mintNft, hasNft } = stateManager.useStateData('community-functions')();
  const memberData = stateManager.useStateData('member-data')();
  const points = stateManager.useStateData('member-points')();

  // Local state data
  const [registering, setRegistering] = useState(false);
  const [busy, setBusy] = useState(false);
  const [localError, setLocalError] = useState();
  const [detailsVisible, setDetailsVisible] = useState(false);
  const [confirmDelete, setConfirmDelete] = useState(false);
  const [ownsNft, setOwnsNft] = useState(false);
  let errorTimer;

  useEffect(() => {
    hasNft('0x35d0d209A821AB63665016e1229aba16f52906AB')
    .then(setOwnsNft)
    .catch(console.warn);
  }, []);

  function setError(error) {
    if (errorTimer) {
      clearTimeout(errorTimer);
      errorTimer = null;
    }
    setLocalError(error);
    errorTimer = setTimeout(() => setLocalError(undefined), 5000);
  }

  function updateUser(data) {
    setRegistering(true);
    updateData(data)
    .catch(setError)
    .finally(() => setRegistering(false));
  }

  function deleteAccount() {
    setBusy(true);
    deregister()
    .catch(setError)
    .finally(() => setBusy(false));
  }

  function mint(address) {
    setBusy(true);
    mintNft(address)
    .then(() => hasNft(address))
    .then(setOwnsNft)
    .catch(setError)
    .finally(() => setBusy(false));
  }

  return (
    <div className="dashboard">

      <div className="page-width-section title-section">
        <span className="page-title">
          Your Bubble Community Account
        </span>
        <p className="page-summary">
          Welcome to your Bubble Community dashboard.
          From here you can manage your account and access all our exclusive member-only benefits.
        </p>
      </div>

      <div className="divider"></div>

      <div className="page-width-section center">
        <div className="points-column">
          <span className="points">Your Points: {'' + points}</span>
          <a className="small-link" href="https://polygonscan.com/token/0xEf9eD7fdAB95b8Bc02CFe05d869c3e08E7F102d1#balances" target="_blank">leaderboard</a>
        </div>
      </div>

      <div className="page-width-section center">
        <span className="points">Your NFTs</span>
        {!ownsNft && <div className="community-notice">All Bubble / Rehide Partnership NFTs have now been minted.<br/><br/>Check back here regularly for more NFTs!</div>}
        {ownsNft && <a href="https://polygonscan.com/address/0x35d0d209A821AB63665016e1229aba16f52906AB"><img className="nft-image" src={rehideNftImage} alt="rehide-nft"></img></a>}
      </div>

      <div className="divider"></div>

      {detailsVisible && 
        <div className="page-width-section">

          <span className="section-title">Your Account</span>

          <p className="disclaimer">
            Your data is encrypted and stored securely in an off-chain bubble on the Bubble Private Cloud. 
            You have full control of your data and can delete it at any time.  
            Bubble Protocol has read access to your data for the purposes of implementing its referral program and other community promotions.
            Your data will never be shared with anyone.
          </p>

          <SocialsForm buttonText="Update" onRegister={updateUser} registering={registering} initialValues={memberData} connectButton={false} registerButton={!confirmDelete && !busy} />

          {confirmDelete && !busy &&

            <div className="warning">
              <p>Are you sure?</p>
              <p>
                If you delete your account you won't be eligible for any more community rewards.
                Any points and NFTs you have earned up to now are safe but you won't be able to claim any future points or NFTs.
              </p>
              <div className="delete-link" onClick={deleteAccount}>YES, DELETE MY ACCOUNT</div>
              <div className="section-link" onClick={() => setConfirmDelete(false)}>Cancel</div>
            </div>
          }
          {!confirmDelete && !busy && <div className="delete-link" onClick={() => setConfirmDelete(true)}>Delete Your Account</div>}

        </div>
      }

      <div className="page-width-section">
        {/* Logout */}
        {!localError && !confirmDelete && !busy && !registering && 
          <div className="account-links">
            <div className="section-link" onClick={() => setDetailsVisible(!detailsVisible)}>{detailsVisible ? "Hide Your Account" : "Manage Your Account"}</div>
            <div className="section-link" onClick={logout}>Logout</div>
          </div>
        }

        {/* Loader */}
        {busy && <div className="loader small"></div>}

        {/* Error log */}
        {appError && <span className='error-text center'>Error!<br/>{formatError(appError)}</span>}
        {!busy && localError && <span className='error-text center'>{formatError(localError)}</span>}

      </div>

    </div>
  );

}


function formatError(error) {
  if (error.code === 'username-registered') return "One of your usernames has already been registered to a different user";
  if (error.cause && error.cause.code === 4001) return "User rejected";
  if (error.cause && error.cause.code === -32603) return <span>Your wallet failed to send the transaction. Please try again.<br/>({error.details})</span>;
  return error.details || error.message || error;
}

