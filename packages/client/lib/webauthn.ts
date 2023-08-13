import { client, utils, parsers } from '@passwordless-id/webauthn'
import { AuthenticationEncoded, RegistrationEncoded, RegisterOptions, AuthenticateOptions } from '@passwordless-id/webauthn/dist/esm/types'
import { BigNumber } from 'ethers'
import { arrayify, keccak256 } from 'ethers/lib/utils'
import { WebAuthnUtils } from '@client/utils/webauthnutils'

export interface IWebAuthnClient {
    register(challenge:string, name?:string, options?:RegisterOptions ): Promise<RegistrationEncoded>
    authenticate(challenge: string, keyid?: string[], options?: AuthenticateOptions): Promise<AuthenticationEncoded>
}

export interface PassKeySignature {
    id: BigNumber
    r: BigNumber
    s: BigNumber
    authData: Uint8Array
    clientDataPrefix: string
    clientDataSuffix: string
}

export class PassKeyKeyPair {
    keyHash: BigNumber
    pubKeyX: BigNumber
    pubKeyY: BigNumber
    keyId: string
    webAuthnClient: IWebAuthnClient
    name?: string
    aaguid?: string
    manufacturer?: string
    regTime?: EpochTimeStamp

    constructor(keyId: string, pubKeyX: BigNumber, pubKeyY: BigNumber, webAuthnClient: IWebAuthnClient,
                name?: string, aaguid?: string, manufacturer?: string, regTime?: EpochTimeStamp) {
        this.keyHash = BigNumber.from(keccak256(new TextEncoder().encode(keyId)))
        this.pubKeyX = pubKeyX
        this.pubKeyY = pubKeyY
        this.webAuthnClient = webAuthnClient
        this.keyId = keyId
        this.name = name
        this.aaguid = aaguid
        this.manufacturer = manufacturer
        this.regTime = regTime
    }

    static async getValidPassKeyPair(webAuthnClient: IWebAuthnClient, passkeyIds?: string[]): Promise<PassKeyKeyPair> {
        const authData = await webAuthnClient.authenticate(utils.randomChallenge(), passkeyIds, {userVerification: 'required', authenticatorType: 'both'})
        const sig = WebAuthnUtils.getMessageSignature(authData.signature)
        const parsedAuth = parsers.parseAuthentication(authData)
        return new PassKeyKeyPair(parsedAuth.credentialId, BigNumber.from(0), BigNumber.from(0), webAuthnClient, 
            parsedAuth.authenticator.name, parsedAuth.authenticator.aaguid, parsedAuth.authenticator.name, Date.now())
    }

    async signChallenge(payload: string): Promise<PassKeySignature> {
        // ophash is a keccak256 hash of the user operation as a hex string
        // this needs to be base64url encoded from raw bytes of the hash
        const challenge = utils.toBase64url(arrayify(payload)).replace(/=/g, '')
        const authData = await this.webAuthnClient.authenticate(challenge, [this.keyId], {userVerification: 'required', authenticatorType: 'both'})
        const sig = WebAuthnUtils.getMessageSignature(authData.signature)
        const clientDataJSON = new TextDecoder().decode(utils.parseBase64url(authData.clientData))
        const challengePos = clientDataJSON.indexOf(challenge)
        const challengePrefix = clientDataJSON.substring(0, challengePos)
        const challengeSuffix = clientDataJSON.substring(challengePos + challenge.length)
        const authenticatorData = new Uint8Array(utils.parseBase64url(authData.authenticatorData))
        return {
            id: this.keyHash,
            r: sig[0],
            s: sig[1],
            authData: authenticatorData,
            clientDataPrefix: challengePrefix,
            clientDataSuffix: challengeSuffix
        }
    }
}

export class WebAuthnWrapper implements IWebAuthnClient {
    
    constructor() {
    }

    async register(challenge: string, name?:string, options?:RegisterOptions): Promise<RegistrationEncoded> {
        return client.register(name? name : utils.randomChallenge(), challenge, options);
    }
    async authenticate(challenge: string, keyid?: string[] | undefined, options?: AuthenticateOptions): Promise<AuthenticationEncoded> {
        return client.authenticate(keyid? keyid : [], challenge, options);
    }

    public async registerPassKey(payload: string, name?:string): Promise<PassKeyKeyPair> {
        const regData = await this.register(payload, name, 
            {authenticatorType: 'both', userVerification: 'required'});
        const parsedData = parsers.parseRegistration(regData);
    
        let pkey = await WebAuthnUtils.getPublicKeyFromBytes(parsedData.credential.publicKey);
        return new PassKeyKeyPair(parsedData.credential.id, pkey[0], pkey[1], this, 
            name, parsedData.authenticator.aaguid, parsedData.authenticator.name, Date.now());
    }
}