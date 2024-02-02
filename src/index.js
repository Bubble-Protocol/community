// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import React from 'react';
import ReactDOM from 'react-dom/client';
import { RainbowKitProvider, lightTheme } from '@rainbow-me/rainbowkit';
import { WagmiConfig } from 'wagmi';
import UI from './ui/App.js';
import { rainbowKitConfig } from './rainbow-kit.js';
import ImportedHTML from './ui/components/ImportedHTML/ImportedHTML.js';
import { CommunityApp } from './model/App.js';
import './index.css';

/**
 * @dev Add trace and debug commands to the console. Use `console.stackTrace` to dump the stack.
 */
const TRACE_ON = true;
const DEBUG_ON = true;

console.stackTrace = console.trace;
console.trace = TRACE_ON ? Function.prototype.bind.call(console.info, console, "[trace]") : function() {};
console.debug = DEBUG_ON ? Function.prototype.bind.call(console.info, console, "[debug]") : function() {};

/**
 * @dev Construct the model
 */
const app = new CommunityApp();

/**
 * @dev Render the UI
 */
const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <WagmiConfig config={rainbowKitConfig.wagmiConfig}>
      <RainbowKitProvider chains={rainbowKitConfig.chains} theme={lightTheme({borderRadius: 'small'})} >
        <div id="body">
          <ImportedHTML url='/header.html' />
          <div id="page">
            <UI />
            <div className='footer-section'>
              <ImportedHTML url='/footer.html' containerClass='footer-container' />
              <div className='policy-bar'>
                <a className='policy-link' href="https://seedling-d.app/article/0x543686de00b1202dc94b34f9b05816c878e0766427e0f2d86ce916331880e756" target='_blank'>Privacy Policy</a>
              </div>
            </div>
          </div>
        </div>
      </RainbowKitProvider>
    </WagmiConfig>
  </React.StrictMode>
);
