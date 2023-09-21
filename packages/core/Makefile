-include .env

.PHONY: all test clean install update build

all: remove clean install update build test

remove :; @rm -rf lib && rm -rf .git/modules/*

clean  :; @forge clean

install :; @make pre_install run_install post_install

pre_install :; @touch .gitmodules

run_install :; @forge install foundry-rs/forge-std eth-infinitism/account-abstraction openzeppelin/openzeppelin-contracts safe-global/safe-core-protocol --no-commit

post_install :; @rm .gitmodules && pnpm install

update:; @forge update

build:; @forge build --build-info --sizes

test :; @forge test --gas-report -vvv

coverage :; @forge coverage -vv

snapshot :; @forge snapshot

slither :; @forge clean && slither .

format :; @prettier --write src/**/*.sol && prettier --write src/**/**/*.sol

lint :; @solhint src/**/*.sol && solhint src/*.sol

local :; @anvil -m 'test test test test test test test test test test test junk'

fork :; @anvil --fork-url ${$(chain)_RPC_URL} -m 'test test test test test test test test test test test junk'

deploy :; @forge script script/${contract}.s.sol:Deploy${contract} --rpc-url ${$(chain)_RPC_URL}  --private-key ${PRIVATE_KEY} --broadcast --verify --etherscan-api-key ${$(chain)SCAN_API_KEY} -vv

deploy-legacy :; @forge script script/${contract}.s.sol:Deploy${contract} --rpc-url ${$(chain)_RPC_URL}  --private-key ${PRIVATE_KEY} --legacy --broadcast --verify --etherscan-api-key ${$(chain)SCAN_API_KEY} -vv

deploy-local:; @forge script script/${contract}.s.sol:Deploy${contract} --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 -vvv