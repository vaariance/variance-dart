import {create} from "zustand"
import {useState, useEffect} from "react"

interface IMageState {
    activeTab: "overview" | "transactions"
    setActiveTab: (activeView: "overview" | "transactions") => void
}

export const useMageStore = create<IMageState>()((set) => ({
    activeTab: "overview",
    setActiveTab: (activeTab) => set({activeTab}),
}))

export const useStore = <T, F>(store: (callback: (state: T) => unknown) => unknown, callback: (state: T) => F) => {
    const result = store(callback) as F
    const [data, setData] = useState<F>()

    useEffect(() => {
        setData(result)
    }, [result])

    return data
}
