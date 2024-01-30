// Copyright (c) 2023 Bubble Protocol
// Distributed under the MIT software license, see the accompanying
// file LICENSE or http://www.opensource.org/licenses/mit-license.php.

import '@rainbow-me/rainbowkit/styles.css';
import { getDefaultWallets } from '@rainbow-me/rainbowkit';
import { configureChains, createConfig } from 'wagmi';
import { publicProvider } from 'wagmi/providers/public';
import { polygon } from 'wagmi/chains';


/**
 * @dev Configuration of the RainbowKit wallet
 */

const WALLET_CONNECT_PROJECT_ID = 'be5ecff22a547fe5ff88a79a14eb5bae'; // 'YOUR_PROJECT_ID';

const { chains, publicClient } = configureChains(
  [polygon],
  [
    publicProvider()
  ]
);

const { connectors } = getDefaultWallets({
  appName: 'Bubble Protocol Community',
  projectId: WALLET_CONNECT_PROJECT_ID,
  chains
});

const wagmiConfig = createConfig({
  autoConnect: true,
  connectors,
  publicClient
});

export const rainbowKitConfig = {
  wagmiConfig,
  chains
};