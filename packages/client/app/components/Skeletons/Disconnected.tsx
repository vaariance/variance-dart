"use client"
import Image from "next/image"
import {useState} from "react"
import passKeyService from "@client/services/passkeyservice"
import {useStore, useMageStore} from "@client/store"
import {formatAddress} from "@client/utils/address"

const Disconnected = () => {
    const [name, setName] = useState("")
    const [loading, setLoading] = useState(false)
    const store = useStore(useMageStore, (state) => state)

    const [deployed, setDeployed] = useState(false)

    const createPasskeys = async () => {
        setLoading(true)
        const keyPair = await passKeyService.register(name)
        store?.setPassKeysPair(keyPair)
        console.log("keyPair", keyPair)
        setLoading(false)
    }

    const createSafe = async () => {
        setLoading(true)
        const safe = await passKeyService.createSafe("base")
        store?.setSafe(safe)
        console.log("safe", safe)
        setLoading(false)
    }

    const checkIfSafeIsDeployed = async () => {
        setLoading(true)
        const isDeployed = await passKeyService.isSafeDeployed(store?.safe!, "base")
        setDeployed(isDeployed)
        console.log("isDeployed", isDeployed)
        setLoading(false)
    }

    const initialize = async () => {
        setLoading(true)
        const sfModule = await passKeyService.deployModule(store?.passKeysPair)
        sfModule && store?.setPassKeysModule(sfModule)
        console.log("sfModule", sfModule)
        await checkIfSafeIsDeployed()
        setLoading(false)
    }

    const enable = async () => {
        if (!deployed) return
        setLoading(true)
        const response = await passKeyService.enableModule(store?.safe!, store?.passKeysModule!, "base")
        console.log("response", response)
        response && store?.setConnected(true)
        console.log("connected")
        setLoading(false)
    }

    return (
        <section className="py-4 overflow-hidden max-w-screen-xl h-[75vh] mx-auto p-10">
            <div className="container px-4 flex justify-center items-center h-full bg-neutral-50">
                <div className="max-w-md m-auto text-center">
                    <Image
                        className="m-auto animate-pulse"
                        src="/no-wifi.png"
                        alt="https://www.flaticon.com"
                        width={75}
                        height={75}
                    />
                    {!store?.passKeysPair && (
                        <div>
                            <h2 className="font-heading mb-3 text-2xl font-semibold">Generate a PassKey</h2>
                            <p className="mb-7 text-neutral-500">
                                Generate a passkey to continue. This will be used to sign your transactions.
                            </p>
                            <div className="gap-4">
                                <input
                                    type="text"
                                    placeholder="Enter your Name"
                                    className="w-full max-w-xs mt-3 mr-3 px-3 py-2 text-gray-500 bg-transparent outline-none border focus:border-teal-600 shadow-sm rounded-lg"
                                    onChange={(e) => setName(e.target.value)}
                                />
                                {loading ? (
                                    renderSpiner()
                                ) : (
                                    <button
                                        className="px-4 py-2 text-white bg-gray-600 rounded-3xl duration-150 hover:bg-gray-500 active:bg-gray-700"
                                        onClick={createPasskeys}
                                    >
                                        Create
                                    </button>
                                )}
                            </div>
                        </div>
                    )}

                    {store?.passKeysPair && !store?.safe && (
                        <div>
                            <h2 className="font-heading mb-3 text-2xl font-semibold">Deploy your Safe</h2>
                            <p className="mb-7 text-neutral-500">PassKey saved! Deploy a Safe to continue.</p>
                            <div className="gap-4">
                                {loading ? (
                                    renderSpiner()
                                ) : (
                                    <button
                                        className="px-4 py-2 text-white bg-gray-600 rounded-3xl duration-150 hover:bg-gray-500 active:bg-gray-700"
                                        onClick={createSafe}
                                    >
                                        Create Safe
                                    </button>
                                )}
                            </div>
                        </div>
                    )}

                    {store?.passKeysPair && store?.safe && !store?.passKeysModule && (
                        <div>
                            <h2 className="font-heading mb-3 text-2xl font-semibold">Create Passkeys Module</h2>
                            <p className="mb-7 text-neutral-500">
                                Your safe will be deployed shortly! Transfer eth to your safe address.
                                <button
                                    className="text-blue-600 inline-flex items-center"
                                    onClick={() => navigator.clipboard.writeText(store.safe)}
                                >
                                    {formatAddress(store.safe)}
                                    <svg
                                        fill="currentColor"
                                        viewBox="0 0 20 20"
                                        className="w-4 h-4 mr-3"
                                        xmlns="http://www.w3.org/2000/svg"
                                        aria-hidden="true"
                                    >
                                        <path d="M7 3.5A1.5 1.5 0 018.5 2h3.879a1.5 1.5 0 011.06.44l3.122 3.12A1.5 1.5 0 0117 6.622V12.5a1.5 1.5 0 01-1.5 1.5h-1v-3.379a3 3 0 00-.879-2.121L10.5 5.379A3 3 0 008.379 4.5H7v-1z" />
                                        <path d="M4.5 6A1.5 1.5 0 003 7.5v9A1.5 1.5 0 004.5 18h7a1.5 1.5 0 001.5-1.5v-5.879a1.5 1.5 0 00-.44-1.06L9.44 6.439A1.5 1.5 0 008.378 6H4.5z" />
                                    </svg>
                                </button>
                            </p>
                            <p className="mb-7 text-neutral-500"> meanwhile, initialize your passkeys onChain.</p>
                            <div className="gap-4">
                                {loading ? (
                                    renderSpiner()
                                ) : (
                                    <button
                                        className="px-4 py-2 text-white bg-gray-600 rounded-3xl duration-150 hover:bg-gray-500 active:bg-gray-700"
                                        onClick={initialize}
                                    >
                                        Initialize
                                    </button>
                                )}
                            </div>
                        </div>
                    )}

                    {store?.passKeysPair && store?.safe && store?.passKeysModule && !store.connected && (
                        <div>
                            <h2 className="font-heading mb-3 text-2xl font-semibold">Enable Passkeys Module</h2>
                            {!deployed ? (
                                <p className="mb-7 text-red-500">
                                    Your PassKeys Module has been deployed onchain! but your safe is still pending.
                                    transfer eth to your safe address{" "}
                                    <span
                                        className="text-blue-600 inline-flex items-center"
                                        onClick={() => navigator.clipboard.writeText(store.safe)}
                                    >
                                        {formatAddress(store.safe)}
                                        <svg
                                            fill="currentColor"
                                            viewBox="0 0 20 20"
                                            className="w-4 h-4 mr-3"
                                            xmlns="http://www.w3.org/2000/svg"
                                            aria-hidden="true"
                                        >
                                            <path d="M7 3.5A1.5 1.5 0 018.5 2h3.879a1.5 1.5 0 011.06.44l3.122 3.12A1.5 1.5 0 0117 6.622V12.5a1.5 1.5 0 01-1.5 1.5h-1v-3.379a3 3 0 00-.879-2.121L10.5 5.379A3 3 0 008.379 4.5H7v-1z" />
                                            <path d="M4.5 6A1.5 1.5 0 003 7.5v9A1.5 1.5 0 004.5 18h7a1.5 1.5 0 001.5-1.5v-5.879a1.5 1.5 0 00-.44-1.06L9.44 6.439A1.5 1.5 0 008.378 6H4.5z" />
                                        </svg>
                                    </span>
                                </p>
                            ) : (
                                <p className="mb-7 text-neutral-500">
                                    Your PassKeys Module has been deployed onchain! last step. enable it for your safe
                                </p>
                            )}
                            <div className="gap-4">
                                {loading ? (
                                    renderSpiner()
                                ) : (
                                    <button
                                        className="px-4 py-2 text-white bg-gray-600 rounded-3xl duration-150 hover:bg-gray-500 active:bg-gray-700"
                                        onClick={deployed ? enable : checkIfSafeIsDeployed}
                                    >
                                        {deployed ? "Enable" : "Check"}
                                    </button>
                                )}
                            </div>
                        </div>
                    )}
                </div>
            </div>
        </section>
    )
}

export const renderSpiner = (): JSX.Element => {
    return (
        <div role="status">
            <svg
                aria-hidden="true"
                className="inline w-8 h-8 mr-2 text-gray-200 animate-spin dark:text-gray-600 fill-green-500"
                viewBox="0 0 100 101"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
            >
                <path
                    d="M100 50.5908C100 78.2051 77.6142 100.591 50 100.591C22.3858 100.591 0 78.2051 0 50.5908C0 22.9766 22.3858 0.59082 50 0.59082C77.6142 0.59082 100 22.9766 100 50.5908ZM9.08144 50.5908C9.08144 73.1895 27.4013 91.5094 50 91.5094C72.5987 91.5094 90.9186 73.1895 90.9186 50.5908C90.9186 27.9921 72.5987 9.67226 50 9.67226C27.4013 9.67226 9.08144 27.9921 9.08144 50.5908Z"
                    fill="currentColor"
                />
                <path
                    d="M93.9676 39.0409C96.393 38.4038 97.8624 35.9116 97.0079 33.5539C95.2932 28.8227 92.871 24.3692 89.8167 20.348C85.8452 15.1192 80.8826 10.7238 75.2124 7.41289C69.5422 4.10194 63.2754 1.94025 56.7698 1.05124C51.7666 0.367541 46.6976 0.446843 41.7345 1.27873C39.2613 1.69328 37.813 4.19778 38.4501 6.62326C39.0873 9.04874 41.5694 10.4717 44.0505 10.1071C47.8511 9.54855 51.7191 9.52689 55.5402 10.0491C60.8642 10.7766 65.9928 12.5457 70.6331 15.2552C75.2735 17.9648 79.3347 21.5619 82.5849 25.841C84.9175 28.9121 86.7997 32.2913 88.1811 35.8758C89.083 38.2158 91.5421 39.6781 93.9676 39.0409Z"
                    fill="currentFill"
                />
            </svg>
            <span className="sr-only">Loading...</span>
        </div>
    )
}

export default Disconnected
