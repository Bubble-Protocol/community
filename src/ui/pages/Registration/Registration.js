// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import React from "react";
import './style.css';
import communityImage from "../../images/community.png";


/**
 * @dev The main application screen
 */

export function Registration() {

  return (
    <>
        <div className="hero-section community-page">
            <div className="titles">
                <span className="title">
                  Welcome To The Bubble Community
                </span>
                <span className="subtitle">
                  Register to join our on-chain community and start collecting Bubble NFTs
                </span>
            </div>
            <div className="hero-image-frame">
                <img className="hero-image community-page" src={communityImage} alt="hero"/>
                <img className="bubble2" src="/images/bubble2.png" alt="bubble"/>
                <img className="bubble3" src="/images/bubble1.png" alt="bubble"/>
                <img className="bubble1" src="/images/bubble3.png" alt="bubble"/>
            </div>
        </div>

        <div className="page-width-section">
          <span className="section-title indent-with-feature">Register</span>
          <div className="button-row indent-with-feature">
            <a href="https://github.com/Bubble-Protocol/bubble-sdk" target="_blank"><div className="cta-button-solid">Start Building</div></a>
            <a href="how-it-works.html"><div className="cta-button-hollow">How It Works</div></a>
          </div>
        </div>

        <div className="button-row">
          <a href="https://github.com/Bubble-Protocol/bubble-sdk" target="_blank"><div className="cta-button-solid">Register</div></a>
        </div>
    </>
  );

}
