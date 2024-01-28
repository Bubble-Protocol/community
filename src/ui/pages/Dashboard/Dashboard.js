// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import React from "react";
import './style.css';
import communityImage from "../../images/community.png";


export function Dashboard() {

  return (
    <>
        <div className="hero-section community-page">
            <div className="titles">
                <span className="title">
                  Your Dashboard
                </span>
                <span className="subtitle">
                  Welcome To Your Bubble Community Dashboard
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
          <p>TODO</p>
        </div>

    </>
  );

}
