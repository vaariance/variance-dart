"use client"
import Image from "next/image"
import {useState} from "react"
import passKeyService from "@client/services/passkeyservice"
import {useStore, useMageStore} from "@client/store"

const Disconnected = () => {
    const [name, setName] = useState("")
    const store = useStore(useMageStore, (state) => state)

    const createPasskeys = async () => {
        const keyPair = await passKeyService.register(name)
        store?.setPassKeysPair(keyPair)
        console.log("keyPair", keyPair)
    }

    const createSafe = async () => {
        const safe = await passKeyService.createSafe("base")
        store?.setSafe(safe)
        console.log("safe", safe)
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
                                <button
                                    className="px-4 py-2 text-white bg-gray-600 rounded-3xl duration-150 hover:bg-gray-500 active:bg-gray-700"
                                    onClick={createPasskeys}
                                >
                                    Create
                                </button>
                            </div>
                        </div>
                    )}

                    {store?.passKeysPair && !store?.safe && (
                        <div>
                            <h2 className="font-heading mb-3 text-2xl font-semibold">Deploy your Safe</h2>
                            <p className="mb-7 text-neutral-500">PassKey saved! Deploy a Safe to continue.</p>
                            <div className="gap-4">
                                <button
                                    className="px-4 py-2 text-white bg-gray-600 rounded-3xl duration-150 hover:bg-gray-500 active:bg-gray-700"
                                    onClick={createSafe}
                                >
                                    Create Safe
                                </button>
                            </div>
                        </div>
                    )}
                </div>
            </div>
        </section>
    )
}

export default Disconnected
