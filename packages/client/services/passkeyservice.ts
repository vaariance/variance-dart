import {utils} from "@passwordless-id/webauthn"
import SafeApiKit from "@safe-global/api-kit"
import Safe, {EthersAdapter, SafeAccountConfig, SafeFactory} from "@safe-global/protocol-kit"
import {ethers} from "ethers"
import {PassKeyKeyPair, WebAuthnWrapper} from "../lib/webauthn"
import ccipSenderAbi from "./abis/ccip.json"
import passkeysAbi from "./abis/passkeys.json"

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

    constructor() {
        super()
        this.client = new WebAuthnWrapper()
        this.passkeysAbi = passkeysAbi
        this.ccipSenderAbi = ccipSenderAbi
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

    async sign(execHash: string, passKeyPair: PassKeyKeyPair) {
        return await passKeyPair.signChallenge(execHash)
    }

    // returns the exec hash from the passkeys module
    async getExecHash(passKeysModuleAddress: string, safe: string, to: string, value = 0) {
        const wallet = new ethers.Wallet(this.wallet, this.baseProvider)
        const contract = new ethers.Contract(passKeysModuleAddress, this.passkeysAbi.abi, wallet)

        const tx = contract.generateExecHash(safe, to, value, wallet.getTransactionCount())
        return tx
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
    async deployModule(passkey: PassKeyKeyPair) {
        const factory = new ethers.ContractFactory(
            [], // ABI, not needed for constructor
            this.passkeysAbi.bytecode,
            new ethers.Wallet(this.wallet, this.baseProvider)
        )
        const contract = await factory.deploy(passkey.keyId, passkey.pubKeyX, passkey.pubKeyY)
        await contract.deployed()
        return contract.address
    }

    // needs to manually enable the module on the safe
    async enableModule(safeAddress: string, moduleAddress: string, network: "base" | "op") {
        const safeSdk = await Safe.create({
            ethAdapter: network === "base" ? this.baseAdapter : this.opAdapter,
            safeAddress,
        })
        const safeTransaction = await safeSdk.createEnableModuleTx(moduleAddress)
        const txResponse = await safeSdk.executeTransaction(safeTransaction)
        await txResponse.transactionResponse?.wait()
        return txResponse
    }

    // deploys the ccip sender
    async deployCCIPSender(safeAddress: string) {
        const factory = new ethers.ContractFactory(
            [], // ABI, not needed for constructor
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

    // encodes the call args to be sent to the safe
    async encodeCallArgs() {}

    // executes a transaction from a safe module
    async executeFromModule() {}

    // sends a ccip transaction from safe
    async ccipSend() {
        // execute from module
    }
}

const passKeyService = PassKeyService.getOrCreateService()
export type passKeyService = typeof passKeyService
export default passKeyService
