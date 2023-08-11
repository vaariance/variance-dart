-include .env

.PHONY:  clean install update build

remove :; @$(MAKE) -C packages/$(target) remove

clean :; @$(MAKE) -C packages/$(target) clean

install :; @$(MAKE) -C packages/$(target) install-inner

# Update Dependencies
update:; @$(MAKE) -C packages/$(target) update

# Build the project
build:; @$(MAKE) -C packages/$(target) build

test :; @$(MAKE) -C packages/$(target) test

snapshot :; @$(MAKE) -C packages/$(target) snapshot

slither :; @$(MAKE) -C packages/$(target) slither

# Format
format :; @prettier --write packages/$(target)/src/**/*.sol && prettier --write packages/$(target)/src/**/**/*.sol

# solhint should be installed globally
lint :; @solhint packages/$(target)/src/**/*.sol && solhint packages/$(target)/src/*.sol

# Deploy
deploy :; @$(MAKE) -C packages/$(target) deploy

local :; @anvil -m 'test test test test test test test test test test test junk'

fork :; @anvil --fork-url $${$(CHAIN)_RPC_URL} -m 'test test test test test test test test test test test junk'

deploy-local :; @forge script packages/$(target)/script/${contract}.s.sol:Deploy${contract} --rpc-url http://localhost:8545  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast 

factory-deploy :; @cast send --interactive 1 --rpc-url $${$(CHAIN)_RPC_URL} --json 0xfactoryAddress "deploy(address admin, uint256 _salt, Type paymasterType)" ${admin} ${salt} ${choice}