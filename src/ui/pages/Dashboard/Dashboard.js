// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import React, { useState } from "react";
import './style.css';
import { SocialsForm } from "../Registration/components/SocialsForm";
import { stateManager } from "../../../state-context";


export function Dashboard() {

  // Model state data
  const appError = stateManager.useStateData('error')();
  const { logout } = stateManager.useStateData('wallet-functions')();
  const { updateData, deregister } = stateManager.useStateData('community-functions')();
  const memberData = stateManager.useStateData('member-data')();

  // Local state data
  const [registering, setRegistering] = useState(false);
  const [deleting, setDeleting] = useState(false);
  const [registerError, setRegisterError] = useState(false);
  const [detailsVisible, setDetailsVisible] = useState(false);
  const [confirmDelete, setConfirmDelete] = useState(false);

  function updateUser(data) {
    setRegistering(true);
    updateData(data)
    .catch(setRegisterError)
    .finally(() => setRegistering(false));
  }

  function deleteAccount() {
    setDeleting(true);
    deregister()
    .catch(setRegisterError)
    .finally(() => setDeleting(false));
  }

  return (
    <div className="dashboard">

      <div className="page-width-section title-section">
        <span className="page-title">
          Your Bubble Community Account
        </span>
        <p className="page-summary">
          Welcome to your Bubble Community Dashboard.
          From here you can manage your account and access all our exclusive member-only benefits.
        </p>
      </div>

      <div className="page-width-section center">
        <a className="community-link" href="">Click Here to join our exclusive member-only Galxe campaigns and start earning community rewards!</a>
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

          <SocialsForm buttonText="Update" onRegister={updateUser} registering={registering} initialValues={memberData} connectButton={false} registerButton={!confirmDelete && !deleting} />

          {confirmDelete && !deleting &&

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
          {!confirmDelete && !deleting && <div className="delete-link" onClick={() => setConfirmDelete(true)}>Delete Your Account</div>}
          {deleting && <div className="loader small"></div>}

          {/* Error log */}
          {appError && <span className='error-text center'>Error!<br/>{formatError(appError)}</span>}
          {registerError && <span className='error-text center'>Registration Failed!<br/>{formatError(registerError)}</span>}

        </div>
      }

      <div className="page-width-section">
      {!confirmDelete && !deleting && !registering && <div className="section-link" onClick={logout}>Logout</div>}
      </div>

    </div>
  );

}


function formatError(error) {
  if (error.code === 'username-registered') return "One of your usernames has already been registered to a different user";
  return error.details || error.message || error;
}

