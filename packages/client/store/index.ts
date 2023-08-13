import {PassKeyKeyPair} from "@client/lib/webauthn"
import {useEffect, useState} from "react"
import {create} from "zustand"
import {createJSONStorage, persist} from "zustand/middleware"
interface IMageState {
    connected: boolean
    setConnected: (connected: boolean) => void

    safe: string
    setSafe: (safe: string) => void

    passKeysPair: PassKeyKeyPair | undefined
    setPassKeysPair: (passKeysPair: PassKeyKeyPair) => void

    passKeysModule: string
    setPassKeysModule: (passKeysModule: string) => void

    CCIPModule: string
    setCCIPModule: (CCIPModule: string) => void

    activeTab: "overview" | "transactions"
    setActiveTab: (activeView: "overview" | "transactions") => void
}

export const useMageStore = create<IMageState>()(
    persist(
        (set) => ({
            connected: false,
            setConnected: (connected) => set({connected}),

            safe: "",
            setSafe: (safe) => set({safe}),

            passKeysPair: undefined,
            setPassKeysPair: (passKeysPair) => set({passKeysPair}),

            passKeysModule: "",
            setPassKeysModule: (passKeysModule) => set({passKeysModule}),

            CCIPModule: "",
            setCCIPModule: (CCIPModule) => set({CCIPModule}),

            activeTab: "overview",
            setActiveTab: (activeTab) => set({activeTab}),
        }),
        {
            name: "0x4b1aafe0f3026a7149870f449a15e610283b3a1335f158999d91f0e0a8199900",
            storage: createJSONStorage(() => localStorage),
        }
    )
)

export const useStore = <T, F>(store: (callback: (state: T) => unknown) => unknown, callback: (state: T) => F) => {
    const result = store(callback) as F
    const [data, setData] = useState<F>()

    useEffect(() => {
        setData(result)
    }, [result])

    return data
}
