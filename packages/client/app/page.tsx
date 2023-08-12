"use client"
import {useMageStore, useStore} from "@client/store"
import {useSession} from "next-auth/react"
import Disconnected from "./components/Skeletons/Disconnected"
import Table from "./components/Skeletons/Table"
import Overview from "./components/Tabs/Overview"
import Send from "./components/Tabs/Send"
import Transactions from "./components/Tabs/Transactions"

export default function Home() {
    const activeTab = useStore(useMageStore, (state) => state.activeTab)
    const {data: session, status} = useSession()
    const loading = status === "loading"

    const renderActiveTab = () => {
        switch (activeTab) {
            case "transactions":
                return !session && loading ? <Table /> : <Transactions tx={[]} />
            case "send":
                return !session && loading ? <Table /> : <Send />
            default:
                return !session && loading ? <Table /> : <Overview accounts={[]} />
        }
    }

    if (!session && !loading) return <Disconnected />
    return <div className="h-[75vh]">{renderActiveTab()}</div>
}
