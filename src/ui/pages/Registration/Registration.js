// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import React from "react";
import './style.css';


/**
 * @dev The main application screen
 */

export function Registration() {

  return (
    <>
        <div class="hero-section">
            <div class="titles">
                <span class="title">
                  Welcome To The Bubble Community
                </span>
                <span class="subtitle">
                  Register to join our on-chain community and start collecting Bubble NFTs
                </span>
            </div>
            <div class="learn-hero-image-frame">
                <img class="hero-image" src="/images/learn-hero.png" alt="hero"/>
                <img class="bubble1" src="/images/bubble1.png" alt="bubble"/>
                <img class="bubble2" src="/images/bubble2.png" alt="bubble"/>
                <img class="bubble3" src="/images/bubble3.png" alt="bubble"/>
                <img class="bubble4" src="/images/bubble4.png" alt="bubble"/>
            </div>
        </div>

        <div class="page-width-section">
          <span class="section-title indent-with-feature">Register</span>
          <div class="button-row indent-with-feature">
            <a href="https://github.com/Bubble-Protocol/bubble-sdk" target="_blank"><div class="cta-button-solid">Start Building</div></a>
            <a href="how-it-works.html"><div class="cta-button-hollow">How It Works</div></a>
          </div>
        </div>

        <div class="button-row">
          <a href="https://github.com/Bubble-Protocol/bubble-sdk" target="_blank"><div class="cta-button-solid">Register</div></a>
        </div>
    </>
  );

}
