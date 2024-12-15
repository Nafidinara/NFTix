// src/components/common/WalletButton.jsx
import { useWeb3Modal } from '@web3modal/wagmi/react'
import { useAccount } from 'wagmi'
import { useState } from 'react'

const WalletButton = () => {
  const { open } = useWeb3Modal()
  const { address, isConnected } = useAccount()
  const [isLoading, setIsLoading] = useState(false)

  const handleClick = async () => {
    try {
      setIsLoading(true)
      await open()
    } catch (error) {
      console.error('Failed to open Web3Modal', error)
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <button 
      onClick={handleClick}
      disabled={isLoading}
      className="your-button-classes"
    >
      {isConnected ? (
        <span>
          {`${address.slice(0, 6)}...${address.slice(-4)}`}
        </span>
      ) : (
        <span>
          {isLoading ? 'Connecting...' : 'Connect Wallet'}
        </span>
      )}
    </button>
  )
}

export default WalletButton