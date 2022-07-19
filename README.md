# Gro Merkle Vestor Contract

The merkle vestor let's the operator setup the contract with a merkle root that distributes tokens to users.
The advantage with using a merkle tree is not having to setup vesting positions for all the users, as the users verify their claim with a merkle proof. Users are able to make claims for their vested positions on an ongoing basis. The operator is required to send the distribution token to the contract, the operator can also sweep this token from the contract.

## Installation and Testing

### Installation

This project uses foundry, you can follow the installation guide here https://book.getfoundry.sh/getting-started/installation.html

When you have installed foundry run the following command to install dependencies:

```bash
forge install
```

To compile the contracts run:
```bash
forge build
```

### Running Tests

To run integration tests:
```bash
# first load .env files
source .env

# run tests
forge test --fork-url $ETH_RPC_URL --match-path 'test/integration/*.sol'
```

To run unit tests:
```bash
forge test --match-path 'test/unit/*.sol'
```

To run fuzz tests:
```bash
forge test --match-path 'test/fuzz/*.sol'
```

### Running Deployment Script

```bash
# To load the variables in the .env file
source .env

# To deploy and verify our contract
forge script script/DeploymentScript.s.sol:DeploymentScript --rpc-url $RPC_URL  --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_KEY -vvvv
```

To test locally on mainnet fork:
``` bash
# load .env variables
source .env

# First startup anvil mainnet fork
anvil --fork-url $MAINNET_FORK_URL

# run script against fork to deploy contract
forge script script/DeploymentScript.s.sol:DeploymentScript --rpc-url $LOCAL_RPC_URL  --private-key $PRIVATE_KEY --broadcast -vvvv
```

## About Gro

Gro protocol is a stablecoin yield aggregator that tranches risk and yield. The first two products built on it are the PWRD stablecoin with deposit protection and yield, and Vault with leveraged stablecoin yields.

<p align="center">
  <img src="https://user-images.githubusercontent.com/59924029/176437952-f34274d7-219a-41ad-8a64-45dd7be2cc28.svg" height="100" />
</p>

