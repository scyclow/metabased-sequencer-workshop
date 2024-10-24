# Load environment variables
-include .env

# run this command to fork metabased testnet
fork-metabased-testnet :; anvil --fork-url metabased_testnet

# deployment commands against forked metabased testnet

# This private key is common knowledge, you should not use them on any network other than this dev network. Using these private keys on mainnet, or even a testnet, will most likely result in a loss of funds.
fork-allowlist-module-deploy-and-run :; forge script script/AllowlistModuleDeploymentAndSetup.s.sol:AllowlistModuleDeploymentAndSetup --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast -vvv

fork-nft-module-deploy-and-run :; forge script script/NFTModuleDeploymentAndSetup.s.sol:NFTModuleDeploymentAndSetup --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast -vvv



# deployment commands against the actual metabased testnet
allowlist-module-deploy-and-run :; forge script script/AllowlistModuleDeploymentAndSetup.s.sol:AllowlistModuleDeploymentAndSetup --rpc-url metabased_testnet --private-key ${PRIVATE_KEY} --broadcast -vvv

nft-module-deploy-and-run :; forge script script/NFTModuleDeploymentAndSetup.s.sol:NFTModuleDeploymentAndSetup --rpc-url metabased_testnet --private-key ${PRIVATE_KEY} --broadcast -vvv
