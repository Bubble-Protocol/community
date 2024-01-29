/**
 * Social Media utility functions
 */

export function validateUsername(text, hostname) {
  const social = extractUsername(text, hostname);
  return social 
    && social.length > 0;
}

export function extractUsername(text, hostname) {
  let social;
  if (hostname) {
    try {
      const url = new URL(text, hostname);
      if (url.pathname.length > 0) {
        const parts = url.pathname.split('/');
        if (parts.length === 2) {
          social = parts[1].replace(/^[@#]/, '');
        }
      }
    }
    catch(err) {}
  }
  else {
    if (text && text.length > 0) {
      social = text.trim().replace(/^[@#]/, '');
    }
  }
  return social;
}