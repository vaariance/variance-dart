# foundry-package-template

🍀 ETHGlobal superhack

🥇 first place - best account abstraction on base
🥉 third place - best use of Safe

## Safe compliant passkeys implementation

identity wallet is a passkeys safe module that allows users to execute transactions with their passkeys, eliminating the need to worry about private keys or managing private keys.
due to the way safe core works, the private key signers are still active.

but with this implementation, instead of signer transactions via private keys, the user can use their passkeys to sign transactions.

identity wallet has three important contracts

- Passkeys Module:

the passkeys signature verification module, this module is responsible for verifying the passkeys signature and executing the safe transaction.

- CCIPSender:

a token sender contract that enables the safe to transfer assets from one chain to another

- IDRecover:

a worldID verifying contract that uses worlId for passkeys recovery.

however due to the low interop between `CCIP - SAFE - OPTIMISM - WORLDCOIN` based on current chains
I was not able to attach the IDRecover contract to the passkeys module on base testnet.
also, i was not able to use the CCIPSender contract with the safes ion base.
and also did not have access to the developer portal.

so the minimal POC was `SAFE - BASE`

front-end:

uses covalent api's for getting blockchain data for the safe's

## Getting Started

```shell
# clone the repo
git clone https://github.com/peteruche21/idw-poc

cd idw-poc

# install dependencies
pnpm install

# build the contracts

make build target=core

# cd to the front-end

cd packages/client

# copy .env.example to .env and fill in the required values
cp .env.example .env

# start the front-end
pnpm dev
```
