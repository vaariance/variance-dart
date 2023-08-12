"use client"
import {useMageStore, useStore} from "@client/store"
import {useEffect, useState} from "react"
import Overview from "./components/Tabs/Overview"
import Transactions from "./components/Tabs/Transactions"
import Disconnected from "./components/Skeletons/Disconnected"
import axios from "axios"
import Table from "./components/Skeletons/Table"
import Send from "./components/Tabs/Send"

export default function Home() {
    const store = useStore(useMageStore, (state) => state)
    const [address, setAddress] = useState("")

    const initApp = async () => {
        // intialize app
    }

    useEffect(() => {
        initApp()
    }, [store?.connected])

    const renderActiveTab = () => {
        switch (store?.activeTab) {
            case "transactions":
                return <Transactions tx={[]} />
            case "send":
                return <Send />
            default:
                return <Overview accounts={[]} />
        }
    }

    if (!store?.connected) return <Disconnected />
    return <div className="h-[75vh]">{renderActiveTab()}</div>
}
