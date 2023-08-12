"use client"
import {useMageStore, useStore} from "@client/store"
import {useSession} from "next-auth/react"
import Disconnected from "./components/Skeletons/Disconnected"
import Table from "./components/Skeletons/Table"
import Overview from "./components/Tabs/Overview"
import Send from "./components/Tabs/Send"
import Transactions from "./components/Tabs/Transactions"
import {useQuery} from "@tanstack/react-query"
import {getBalances, getTransactions} from "@client/utils/query"

export default function Home() {
    const activeTab = useStore(useMageStore, (state) => state.activeTab)
    const {data: session, status} = useSession()
    const loading = status === "loading"

    const {
        data: balances,
        isFetching: bFetching,
        isError: bError,
        isSuccess: bSuccess,
    } = useQuery({
        queryKey: ["balances"],
        queryFn: async () => await getBalances("0x104EDD9708fFeeCd0b6bAaA37387E155Bce7d060"),
    })

    const {
        data: transactions,
        isFetching: tFetching,
        isError: tError,
        isSuccess: tSuccess,
    } = useQuery({
        queryKey: ["transactions"],
        queryFn: async () => await getTransactions("0x104EDD9708fFeeCd0b6bAaA37387E155Bce7d060"),
    })

    const renderActiveTab = () => {
        switch (activeTab) {
            case "transactions":
                return loading ? <Table /> : <Transactions tx={transactions} />
            case "send":
                return loading ? <Table /> : <Send />
            default:
                return loading ? <Table /> : <Overview accounts={balances} />
        }
    }

    // if (!session && !loading) return <Disconnected />
    return <div className="h-[75vh]">{renderActiveTab()}</div>
}
