// src/config/web3.js
import { createWeb3Modal, defaultWagmiConfig } from '@web3modal/wagmi/react'
import { WagmiConfig } from 'wagmi'
import { sepolia } from 'wagmi/chains'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

const projectId = process.env.REACT_APP_WCT_PROJECT_ID

// 2. Create wagmiConfig
const metadata = {
  name: 'NFTix',
  description: 'NFT Ticketing Platform',
  url: 'https://nftix.com', // Ganti dengan URL website Anda
  icons: ['https://avatars.githubusercontent.com/u/37784886']
}

const chains = [sepolia]
const wagmiConfig = defaultWagmiConfig({ chains, projectId, metadata })

// 3. Create modal
createWeb3Modal({ wagmiConfig, projectId, chains })

// 4. Create a client
const queryClient = new QueryClient()

export const Web3Provider = ({ children }) => {
  return (
    <WagmiConfig config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        {children}
      </QueryClientProvider>
    </WagmiConfig>
  )
}