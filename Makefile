# Load environment variables
-include .env

# run this command to fork metabased testnet
fork-metabased-testnet :; anvil --fork-url metabased_testnet

# deployment commands against forked metabased testnet
fork-allowlist-module-deploy-and-run :; forge script script/AllowlistModuleDeploymentAndSetup.s.sol:AllowlistModuleDeploymentAndSetup --rpc-url http://127.0.0.1:8545 --private-key ${PRIVATE_KEY} --broadcast -vvv

fork-nft-module-deploy-and-run :; forge script script/NFTModuleDeploymentAndSetup.s.sol:NFTModuleDeploymentAndSetup --rpc-url http://127.0.0.1:8545 --private-key ${PRIVATE_KEY} --broadcast -vvv


# deployment commands against the actual metabased testnet
allowlist-module-deploy-and-run :; forge script script/AllowlistModuleDeploymentAndSetup.s.sol:AllowlistModuleDeploymentAndSetup --rpc-url metabased_testnet --private-key ${PRIVATE_KEY} --broadcast -vvv

nft-module-deploy-and-run :; forge script script/NFTModuleDeploymentAndSetup.s.sol:NFTModuleDeploymentAndSetup --rpc-url metabased_testnet --private-key ${PRIVATE_KEY} --broadcast -vvv
