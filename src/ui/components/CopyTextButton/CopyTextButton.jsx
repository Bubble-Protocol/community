// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import PropTypes from "prop-types";
import React, { useState } from "react";

export const CopyTextButton = ({ title, copyText, copiedTitle="copied!", className="text-button" }) => {

  const [text, setText] = useState(title);

  function copyToClipboard() {
    navigator.clipboard.writeText(copyText)
    .then(() => {
      setText(copiedTitle);
      setTimeout(() => setText(title), 2000);
    })
    .catch(err => {
      console.warn('Error in copying text: ', err);
    });
  }

  return (
    <div className={className} onClick={copyToClipboard}>{text}</div>
  );
};

CopyTextButton.propTypes = {
  title: PropTypes.string.isRequired,
  copiedTitle: PropTypes.string,
  copyText: PropTypes.string.isRequired,
  className: PropTypes.string
};
