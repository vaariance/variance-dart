-include .env

.PHONY: all test clean install update build

all: remove clean install build test

# Remove modules
remove :; @rm -rf lib && rm -rf ../../.git/modules/*

# Clean the repo
clean  :; @forge clean

# Install dependencies
install-inner :;  @make pre_install run_install post_install

install :; pre_install run_install post_install

pre_install :; @touch .gitmodules

run_install :; @forge install foundry-rs/forge-std smartcontractkit/chainlink-brownie-contracts openzeppelin/openzeppelin-contracts openzeppelin/openzeppelin-contracts-upgradeable axelarnetwork/axelar-gmp-sdk-solidity eth-infinitism/account-abstraction --no-commit

post_install :; @rm .gitmodules

# Update Dependencies
update:; @forge update

# Build the project
build:; @forge build --build-info --sizes

test :; @forge test --gas-report -vvv

coverage :; @forge coverage

snapshot :; @forge snapshot

# Static Analysis
slither :; @forge clean && make build && slither .

# Format
format :; @prettier --write src/**/*.sol && prettier --write src/**/**/*.sol

# solhint should be installed globally
lint :; @solhint src/**/*.sol && solhint src/*.sol

# Deploy
deploy :; @forge script script/${contract}.s.sol:Deploy${contract} --rpc-url $${$(CHAIN)_RPC_URL}  --private-key ${PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${ETHERSCAN_API_KEY}  -vv