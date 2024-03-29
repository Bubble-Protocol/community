// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import React from "react";
import './App.css';
import { Registration } from "./pages/Registration";
import { stateManager } from "../state-context";
import { Home } from "./pages/Home";
import { Dashboard } from "./pages/Dashboard";
import { AdminDashboard } from "./pages/AdminDashboard";


/**
 * @dev The main application screen
 */

function App() {

  const appState = stateManager.useStateData('state')();
  const sessionState = stateManager.useStateData('session-state')();
  const isMember = stateManager.useStateData('isMember')();
  const isMemberAdmin = stateManager.useStateData('isMemberAdmin')();

  const loggedIn = appState === 'initialised' && sessionState === 'logged-in';

  return (
    <>
      {!loggedIn && <Home />}
      {loggedIn && !isMember && !isMemberAdmin && <Registration />}
      {loggedIn && isMember && !isMemberAdmin && <Dashboard />}
      {loggedIn && isMemberAdmin && <AdminDashboard />}
    </>
  );

}

export default App;
