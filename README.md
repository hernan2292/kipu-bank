# KipuBank Smart Contract

A secure banking smart contract built on Ethereum that allows users to deposit and withdraw ETH through personal vaults with built-in security measures.

## 🏦 What does the contract do?

KipuBank is a decentralized banking contract that provides the following functionality:

- **Personal Vaults**: Each user has their own secure vault to store ETH
- **Controlled Deposits**: Users can deposit ETH with a global bank deposit cap
- **Limited Withdrawals**: Withdrawals are restricted to a maximum amount per transaction
- **Activity Tracking**: The contract tracks the total number of deposits and withdrawals

## 🚀 Deployment with Remix

### 📋 Requirements

- Remix IDE (online)
- MetaMask or any Web3 wallet
- Sepolia testnet ETH (for testing)

### 1. **Access Remix IDE**
   Visit [https://remix.ethereum.org](https://remix.ethereum.org)

### 2. **Create the contract file**
   - In Remix, create a new file: `KipuBank.sol`
   - Copy the contract code from [contracts/KipuBank.sol](contracts/KipuBank.sol)
   - Paste it into the Remix editor

### 3. **Compile the contract**
   - Go to the "Solidity Compiler" tab (left sidebar)
   - Select compiler version `0.8.30` or higher
   - Click "Compile KipuBank.sol"
   - Verify there are no errors

### 4. **Deploy the contract**
   - Go to the "Deploy & Run Transactions" tab
   - Select Environment:
     - **Remix VM**: For local testing (no real ETH needed)
     - **Injected Provider - MetaMask**: For testnet deployment (requires Sepolia ETH)

### 5. **Set deployment parameters**
   Before deploying, you need to provide constructor parameters:
   - `_withdrawalLimit`: Maximum ETH withdrawable per transaction (in wei)
   - `_bankCap`: Maximum total ETH deposits allowed (in wei)

   **Example values:**
   - Withdrawal Limit: 1 ETH = `1000000000000000000`
   - Bank Cap: 100 ETH = `100000000000000000000`

### 6. **Execute deployment**
   - Click "Deploy" button
   - Confirm the transaction in MetaMask (if using testnet)
   - Wait for deployment confirmation

### 7. **Verify deployment**
   - Copy the deployed contract address
   - The contract will appear under "Deployed Contracts" section

## 🎯 How to Interact with the Contract in Remix

### External Functions
- `deposit()` - Payable function to deposit ETH
- `withdraw(uint256 amount)` - Withdraw ETH from vault
- `getVaultBalance(address user)` - View function to check vault balance

### View Functions
- `vaults(address)` - Get user's vault balance
- `totalDeposits()` - Get total ETH in the bank
- `depositCount()` - Get total number of deposits
- `withdrawalCount()` - Get total number of withdrawals
- `WITHDRAWAL_LIMIT()` - Get withdrawal limit per transaction
- `BANK_CAP()` - Get maximum bank capacity

## 📜 Smart Contract Address

**Deployed Contract Address**: `0x79D6f42a93F21859d028a2665dB1e81A081db023`
**Network**: `Sepolia`
**Block Explorer**: `https://sepolia.etherscan.io/address/0x79d6f42a93f21859d028a2665db1e81a081db023`

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**⚠️ Disclaimer**: This contract is for educational purposes.