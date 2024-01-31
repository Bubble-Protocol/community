// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import React, { useState } from "react";
import './style.css';
import { stateManager } from "../../../state-context";
import { MemberForm } from "./components/MemberForm";


export function AdminDashboard() {

  // Model state data
  const appError = stateManager.useStateData('error')();
  const { logout } = stateManager.useStateData('wallet-functions')();
  const { deregisterMember, banMember } = stateManager.useStateData('community-functions')();
  const memberData = stateManager.useStateData('member-data')();

  // Local state data
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState(false);
  const [confirmDelete, setConfirmDelete] = useState(false);

  function deregister(data) {
    setError(null);
    setBusy(true);
    deregisterMember(data.account, data)
    .catch(setError)
    .finally(() => setBusy(false));
  }

  function ban(data) {
    setError(null);
    setBusy(true);
    banMember(data.account, data)
    .catch(setError)
    .finally(() => setBusy(false));
  }

  return (
    <div className="admin-dashboard">

      <div className="page-width-section title-section">
        <span className="page-title">
          Bubble Community Admin
        </span>
      </div>

        <div className="page-width-section">

          <span className="section-title">Member Details</span>

          <MemberForm onDeregister={deregister} onBan={ban} initialValues={memberData} hideButtons={busy} />

          {busy && <div className="loader small"></div>}

          {/* Error log */}
          {appError && <span className='error-text center'>Error!<br/>{formatError(appError)}</span>}
          {error && <span className='error-text center'>Registration Failed!<br/>{formatError(error)}</span>}

        </div>

      <div className="page-width-section">
        {!confirmDelete && !busy && <div className="section-link" onClick={logout}>Logout</div>}
      </div>

    </div>
  );

}


function formatError(error) {
  if (error.code === 'username-registered') return "One of your usernames has already been registered to a different user";
  return error.details || error.message || error;
}

