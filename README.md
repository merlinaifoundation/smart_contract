# Merlin Token (MRN) - Deployment Guide

This repository contains the smart contract for the Merlin Token (MRN), an ERC20 merit-based token that rewards valuable contributions to the ecosystem.

## Prerequisites

- [Node.js](https://nodejs.org/) (v14 or higher)
- [npm](https://www.npmjs.com/) (comes with Node.js)
- Ethereum-compatible wallet (like [MetaMask](https://metamask.io/))
- ETH to pay for gas fees (or native tokens if using an alternative network)

## Installation

1. Clone this repository:
```bash
git clone <repository-url>
cd crypto
```

2. Install dependencies:
```bash
npm init -y
npm install hardhat @openzeppelin/contracts @nomiclabs/hardhat-ethers ethers dotenv
```

3. Initialize Hardhat project:
```bash
npx hardhat init
```
Select "Create a JavaScript project" when prompted.

4. Configure environment variables:
   - Create a `.env` file in the project root
   - Add your private key and API URL (like Infura or Alchemy):
```
PRIVATE_KEY=your_private_key_here_without_0x
ALCHEMY_API_KEY=your_alchemy_api_key
INFURA_API_KEY=your_infura_api_key
```
⚠️ NEVER share your private key or upload it to public repositories.

## File Structure

After initialization, your directory should have this structure:

```
crypto/
├── contracts/
│   └── MerlinToken.sol
├── scripts/
│   └── deploy.js
├── test/
├── .env
├── hardhat.config.js
└── README.md
```

## Configuration

1. Modify `hardhat.config.js` to include the networks where you'll deploy:

```javascript
require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;

module.exports = {
  solidity: "0.8.20",
  networks: {
    // Ethereum mainnet (expensive)
    mainnet: {
      url: `https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [`0x${PRIVATE_KEY}`]
    },
    // Goerli testnet (for testing, free ETH)
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [`0x${PRIVATE_KEY}`]
    },
    // Polygon (much cheaper than Ethereum)
    polygon: {
      url: `https://polygon-mainnet.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [`0x${PRIVATE_KEY}`]
    },
    // Mumbai (Polygon testnet, for testing)
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [`0x${PRIVATE_KEY}`]
    }
  }
};
```

2. Create a deployment script in `scripts/deploy.js`:

```javascript
const hre = require("hardhat");

async function main() {
  // Get the deployer's address (will be the initial owner)
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // Deploy the contract
  const MerlinToken = await hre.ethers.getContractFactory("MerlinToken");
  const merlinToken = await MerlinToken.deploy(deployer.address);

  await merlinToken.deployed();

  console.log("MerlinToken deployed to:", merlinToken.address);
  console.log("Owner:", await merlinToken.owner());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

## Deployment

### Testing on Testnet (Recommended)

Before spending real ETH, test on a testnet:

1. Get test ETH tokens:
   - For Goerli: https://goerlifaucet.com/
   - For Mumbai: https://mumbaifaucet.com/

2. Deploy to the testnet:
```bash
npx hardhat run scripts/deploy.js --network goerli
```

### Mainnet Deployment

Once you've tested everything and are ready for the real launch:

```bash
npx hardhat run scripts/deploy.js --network mainnet
```

⚠️ This will require real ETH to pay for gas (approximately $20-50 USD).

### Cost-Effective Alternative: Deploy on Polygon

To save on gas costs:

```bash
npx hardhat run scripts/deploy.js --network polygon
```

## Interacting with the Contract

After deployment, you can interact with your contract:

### Minting Tokens

```javascript
// scripts/mint.js
const hre = require("hardhat");

async function main() {
  const tokenAddress = "YOUR_CONTRACT_ADDRESS_HERE";
  const recipientAddress = "RECIPIENT_ADDRESS_HERE";
  const amount = ethers.utils.parseEther("1000"); // 1000 tokens

  const MerlinToken = await hre.ethers.getContractFactory("MerlinToken");
  const merlinToken = await MerlinToken.attach(tokenAddress);

  // Minting tokens
  console.log("Minting tokens in progress...");
  const tx = await merlinToken.mint(recipientAddress, amount);
  await tx.wait();
  console.log("Tokens minted successfully!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

Run:
```bash
npx hardhat run scripts/mint.js --network mainnet
```

### Enable Transfers

```javascript
// scripts/enableTransfers.js
const hre = require("hardhat");

async function main() {
  const tokenAddress = "YOUR_CONTRACT_ADDRESS_HERE";

  const MerlinToken = await hre.ethers.getContractFactory("MerlinToken");
  const merlinToken = await MerlinToken.attach(tokenAddress);

  console.log("Enabling transfers...");
  const tx = await merlinToken.enableTransfers();
  await tx.wait();
  console.log("Transfers enabled successfully!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

Run:
```bash
npx hardhat run scripts/enableTransfers.js --network mainnet
```

### Configure Recovery Address

```javascript
// scripts/setupRecovery.js
const hre = require("hardhat");

async function main() {
  const tokenAddress = "YOUR_CONTRACT_ADDRESS_HERE";
  const recoveryAddress = "RECOVERY_ADDRESS_HERE";

  const MerlinToken = await hre.ethers.getContractFactory("MerlinToken");
  const merlinToken = await MerlinToken.attach(tokenAddress);

  console.log("Configuring recovery address...");
  const tx = await merlinToken.setupRecoveryAddress(recoveryAddress);
  await tx.wait();
  console.log("Recovery address configured successfully!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

Run:
```bash
npx hardhat run scripts/setupRecovery.js --network mainnet
```

## Contract Verification

To allow users to view and verify the contract code on Etherscan:

1. Install the plugin:
```bash
npm install @nomiclabs/hardhat-etherscan
```

2. Add to `hardhat.config.js`:
```javascript
require("@nomiclabs/hardhat-etherscan");

// Add this to the configuration
etherscan: {
  apiKey: process.env.ETHERSCAN_API_KEY
}
```

3. Verify the contract:
```bash
npx hardhat verify --network mainnet CONTRACT_ADDRESS OWNER_ADDRESS
```

## Listing on Uniswap

After deploying your MRN token and minting an initial amount, you can list it on Uniswap to allow trading between MRN and other cryptocurrencies.

### Prerequisites for Uniswap Listing

1. MRN token deployed and verified
2. Transfers enabled (`enableTransfers()`)
3. An amount of MRN tokens to create the liquidity pool
4. ETH (or the native token of the network you're using) to pair with MRN
5. Additional ETH for gas fees

### Process for Listing on Uniswap V3

1. **Preparation for creating the pool:**
   - Mint an appropriate amount of MRN tokens to your address (at least a few thousand)
   - Ensure you have enough ETH to pair (similar value to MRN tokens)
   - Transfers must be enabled

2. **Create the liquidity pool:**
   
   a. Visit [Uniswap](https://app.uniswap.org/#/pool) and connect your wallet
   
   b. Click on "New Position"
   
   c. If your token doesn't appear automatically, enter the MRN contract address
   
   d. Select ETH (or WETH) as the other token in the pair
   
   e. Choose price range:
      - For V3: select a price range to concentrate liquidity
      - Recommendation: start with a wide range for new tokens
   
   f. Enter the amounts you want to add as initial liquidity:
      - Minimum recommended value is $1,000-5,000 USD equivalent
      - This is crucial for creating a viable initial market

   g. Confirm the transaction and pay the gas

3. **Verify that the pool is active:**
   - Check that your pool appears in "Your Positions"
   - Verify that the token appears in the Uniswap exchange interface

### Script to Approve Uniswap to Use Your Tokens

```javascript
// scripts/approveUniswap.js
const hre = require("hardhat");

async function main() {
  const tokenAddress = "YOUR_CONTRACT_ADDRESS_HERE";
  // Uniswap V3 Router
  const uniswapRouterAddress = "0xE592427A0AEce92De3Edee1F18E0157C05861564";
  // Maximum approval (adjust as needed)
  const maxApproval = ethers.constants.MaxUint256;
  
  const MerlinToken = await hre.ethers.getContractFactory("MerlinToken");
  const merlinToken = await MerlinToken.attach(tokenAddress);

  console.log("Approving Uniswap to use your MRN tokens...");
  const tx = await merlinToken.approve(uniswapRouterAddress, maxApproval);
  await tx.wait();
  console.log("Approval successful! You can now create a pool on Uniswap.");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

Run:
```bash
npx hardhat run scripts/approveUniswap.js --network mainnet
```

### Alternative: Listing on Uniswap on Polygon

For much lower costs, you can create a pool on Uniswap on the Polygon network:

1. Deploy your token on Polygon
2. Follow the same steps above, but connect to Polygon in your wallet
3. Use MATIC instead of ETH to create the pool

### After Creating Liquidity

1. **Share the pool address:**
   - Share your pool URL on social media and communities
   - Example: `https://app.uniswap.org/#/pool/POOL_ID`

2. **Monitor and maintain liquidity:**
   - Watch the pool to ensure there's always sufficient liquidity
   - Consider adding additional liquidity if needed

3. **Promote your token:**
   - Announce the availability of your token on Uniswap
   - Provide tutorials for users to easily buy MRN

## Next Steps

1. **Request listing on aggregators** like CoinMarketCap or CoinGecko
2. **Implement staking or governance** to increase token utility
3. **Consider incentivized liquidity pools** to attract more users

## Security Considerations

- Keep your private key safe
- Consider using a hardware wallet like Ledger or Trezor
- Conduct audits before handling significant amounts
- Implement changes with caution and thorough testing

## Additional Resources

- [Hardhat Documentation](https://hardhat.org/docs)
- [OpenZeppelin Documentation](https://docs.openzeppelin.com/)
- [Ethereum ERC20 Guide](https://ethereum.org/en/developers/docs/standards/tokens/erc-20/)