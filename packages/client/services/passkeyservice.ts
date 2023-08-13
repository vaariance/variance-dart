import {utils} from "@passwordless-id/webauthn"
import SafeApiKit from "@safe-global/api-kit"
import Safe, {EthersAdapter, SafeAccountConfig, SafeFactory} from "@safe-global/protocol-kit"
import {ethers} from "ethers"
import {PassKeyKeyPair, PassKeySignature, WebAuthnWrapper} from "../lib/webauthn"
import ccipSenderAbi from "./abis/ccip.json"
import passkeysAbi from "./abis/passkeys.json"
import tokenAbi from "./abis/transfer.json"

class BaseSafeService {
    baseProvider: ethers.providers.JsonRpcProvider
    baseSTS: string
    baseAdapter: EthersAdapter
    wallet: ethers.Wallet
    baseSafeService: SafeApiKit

    constructor() {
        this.wallet = new ethers.Wallet(process.env.NEXT_PUBLIC_PRIVATE_KEY!)
        //base testnet
        this.baseSTS = "https://safe-transaction-base-testnet.safe.global/"
        this.baseProvider = new ethers.providers.JsonRpcProvider("https://goerli.base.org")
        this.baseAdapter = new EthersAdapter({
            ethers,
            signerOrProvider: new ethers.Wallet(this.wallet, this.baseProvider),
        })
        this.baseSafeService = new SafeApiKit({txServiceUrl: this.baseSTS, ethAdapter: this.baseAdapter})
    }
}

class OpSafeService extends BaseSafeService {
    opProvider: ethers.providers.JsonRpcProvider
    opSTS: string
    opAdapter: EthersAdapter
    opSafeService: SafeApiKit

    constructor() {
        super()
        this.opSTS = "https://safe-transaction-optimism.safe.global/"
        this.opProvider = new ethers.providers.JsonRpcProvider("https://mainnet-sequencer.optimism.io/")
        this.opAdapter = new EthersAdapter({
            ethers,
            signerOrProvider: new ethers.Wallet(this.wallet, this.opProvider),
        })
        this.opSafeService = new SafeApiKit({txServiceUrl: this.opSTS, ethAdapter: this.opAdapter})
    }
}

class PassKeyService extends OpSafeService {
    private static instance: PassKeyService
    private client: WebAuthnWrapper
    passkeysAbi: any
    ccipSenderAbi: any
    tokenAbi: any

    constructor() {
        super()
        this.client = new WebAuthnWrapper()
        this.passkeysAbi = passkeysAbi
        this.ccipSenderAbi = ccipSenderAbi
        this.tokenAbi = tokenAbi
    }

    static getOrCreateService(): PassKeyService {
        if (!PassKeyService.instance) {
            PassKeyService.instance = new PassKeyService()
        }
        return PassKeyService.instance
    }

    getClient() {
        return this.client
    }

    async register(username: string) {
        console.log("Registering user", username)
        return await this.client.registerPassKey(utils.randomChallenge(), username)
    }

    async sign(execHash: string, pkp: PassKeyKeyPair) {
        const _pkp = new PassKeyKeyPair(
            pkp.keyId,
            pkp.pubKeyX,
            pkp.pubKeyY,
            this.client,
            pkp.name,
            pkp.aaguid,
            pkp.manufacturer,
            pkp.regTime
        )
        return await _pkp.signChallenge(execHash)
    }

    // returns the exec hash from the passkeys module
    async getExecHash(passKeysModuleAddress: string, safe: string, to: string, value = 0) {
        const wallet = new ethers.Wallet(this.wallet, this.baseProvider)
        const contract = new ethers.Contract(passKeysModuleAddress, this.passkeysAbi.abi, wallet)
        const nonce = await wallet.getTransactionCount()
        const tx = await contract.generateExecHash(safe, to, value, nonce)
        return {tx, nonce}
    }

    // deploys a safe
    async createSafe(network: "base" | "op") {
        const safeFactory = await SafeFactory.create({
            ethAdapter: network === "base" ? this.baseAdapter : this.opAdapter,
        })
        const safeAccountConfig: SafeAccountConfig = {
            owners: [
                await this.wallet.getAddress(),
                // unknown second owners
                // can pass for passkey service
                await ethers.Wallet.createRandom().address,
            ],
            threshold: 1,
        }

        /* This Safe is tied to owner 1 because the factory was initialized with
          an adapter that had owner 1 as the signer. */
        const safeSdkOwner1 = await safeFactory.deploySafe({safeAccountConfig})
        const safeAddress = await safeSdkOwner1.getAddress()

        return safeAddress
    }

    async isSafeDeployed(safeAddress: string, network: "base" | "op") {
        const safeSdk = await Safe.create({
            ethAdapter: network === "base" ? this.baseAdapter : this.opAdapter,
            safeAddress,
        })
        return safeSdk.isSafeDeployed()
    }

    // deploys the passkeys module
    async deployModule(passkey?: PassKeyKeyPair) {
        try {
            const factory = new ethers.ContractFactory(
                this.passkeysAbi.abi,
                this.passkeysAbi.bytecode,
                new ethers.Wallet(this.wallet, this.baseProvider)
            )
            const contract = await factory.deploy(passkey?.keyId, passkey?.pubKeyX, passkey?.pubKeyY)
            await contract.deployed()
            return contract.address
        } catch (error) {
            console.log(error)
            return
        }
    }

    // needs to manually enable the module on the safe
    async enableModule(safeAddress: string, moduleAddress: string, network: "base" | "op") {
        try {
            const safeSdk = await Safe.create({
                ethAdapter: network === "base" ? this.baseAdapter : this.opAdapter,
                safeAddress,
            })
            const safeTransaction = await safeSdk.createEnableModuleTx(moduleAddress)
            const txResponse = await safeSdk.executeTransaction(safeTransaction)
            await txResponse.transactionResponse?.wait()
            return txResponse
        } catch (error) {
            return
        }
    }

    // deploys the ccip sender
    async deployCCIPSender(safeAddress: string) {
        const factory = new ethers.ContractFactory(
            this.ccipSenderAbi.abi,
            this.ccipSenderAbi.bytecode,
            new ethers.Wallet(this.wallet, this.opProvider)
        )
        const contract = await factory.deploy(
            // router
            "0x261c05167db67B2b619f9d312e0753f3721ad6E8",
            // link
            "0x350a791Bfc2C21F9Ed5d10980Dad2e2638ffa7f6",
            safeAddress
        )
        await contract.deployed()
        return contract.address
    }

    // encodes the call args to be sent to the module
    encodeCallArgs(tokenAddress: string, recipientAddress: string, amount: string) {
        const tokenContract = new ethers.Contract(tokenAddress, tokenAbi)

        const transferData = tokenContract.interface.encodeFunctionData("transfer", [
            recipientAddress,
            ethers.utils.parseEther(amount),
        ])

        return transferData
    }

    encodeSignature(signature: PassKeySignature) {
        const encodedData = ethers.utils.defaultAbiCoder.encode(
            ["uint256", "uint256", "uint256", "bytes", "string", "string"],
            [
                signature.id,
                signature.r,
                signature.s,
                signature.authData,
                signature.clientDataPrefix,
                signature.clientDataSuffix,
            ]
        )
        return encodedData
    }

    // executes a transaction from a safe module
    async executeFromModule(
        passkeysModule: string,
        safe: string,
        tokenAddress: string,
        nonce: number,
        calldata: string,
        signature: PassKeySignature,
        network: "base" | "op"
    ) {
        const wallet = new ethers.Wallet(this.wallet, network === "base" ? this.baseProvider : this.opProvider)
        const contract = new ethers.Contract(passkeysModule, this.passkeysAbi.abi, wallet)

        const tx = await contract.executeWithPasskeys(
            safe,
            tokenAddress,
            0,
            nonce,
            calldata,
            this.encodeSignature(signature)
        )
        await tx.wait()
        return tx.hash
    }

    // sends a ccip transaction from safe
    async ccipSend() {
        // execute from module
    }
}

const passKeyService = PassKeyService.getOrCreateService()
export type passKeyService = typeof passKeyService
export default passKeyService
