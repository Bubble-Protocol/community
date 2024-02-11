// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import React, { useEffect, useState } from "react";
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
  const [error, setError] = useState();
  const [detailsVisible, setDetailsVisible] = useState(false);
  const [confirmDelete, setConfirmDelete] = useState(false);
  const [ownsNft, setOwnsNft] = useState(false);

  useEffect(() => {
    hasNft('0x35d0d209A821AB63665016e1229aba16f52906AB')
    .then(setOwnsNft)
    .catch(console.warn);
  }, []);

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

      <div className="page-width-section center">
        <div className="points-column">
          <span className="points">Your Points: {'' + points}</span>
          <a className="small-link" href="https://polygonscan.com/token/0xe286aB9a1F8362c155b6aaDC7Ad7F40F4bF7115f#balances" target="_blank">leaderboard</a>
        </div>
      </div>

      <div className="page-width-section center">
        <span className="points">Your NFTs</span>
        {!ownsNft && <div className="community-link" onClick={() => mint('0x35d0d209A821AB63665016e1229aba16f52906AB')}>Claim your Bubble / Rehide Partnership NFT!</div>}
        {ownsNft && <a href="https://polygonscan.com/address/0x35d0d209A821AB63665016e1229aba16f52906AB"><img className="nft-image" src={rehideNftImage} alt="rehide-nft"></img></a>}
      </div>

      {!detailsVisible && <div className="section-link" onClick={() => setDetailsVisible(true)}>Manage Your Account</div>}

      {detailsVisible && 
        <div className="page-width-section">

          <div className="section-link" onClick={() => setDetailsVisible(false)}>Hide</div>

          <span className="section-title">Your Details</span>

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
                Any existing community NFTs you have earned until now are safe but you won't be able to claim any future NFTs.
              </p>
              <div className="delete-link" onClick={deleteAccount}>YES, DELETE MY ACCOUNT</div>
              <div className="section-link" onClick={() => setConfirmDelete(false)}>Cancel</div>
            </div>
          }
          {!confirmDelete && !busy && <div className="delete-link" onClick={() => setConfirmDelete(true)}>Delete Your Account</div>}
          {busy && <div className="loader small"></div>}

          {/* Error log */}
          {appError && <span className='error-text center'>Error!<br/>{formatError(appError)}</span>}
          {error && <span className='error-text center'>{formatError(error)}</span>}

        </div>
      }

      <div className="page-width-section">
      {!confirmDelete && !busy && !registering && <div className="section-link" onClick={logout}>Logout</div>}
      </div>

    </div>
  );

}


function formatError(error) {
  if (error.code === 'username-registered') return "One of your usernames has already been registered to a different user";
  return error.details || error.message || error;
}

