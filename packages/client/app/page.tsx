"use client"
import {useMageStore, useStore} from "@client/store"
import {useSession} from "next-auth/react"
import Disconnected from "./components/Skeletons/Disconnected"
import Table from "./components/Skeletons/Table"
import Overview from "./components/Tabs/Overview"
import Transfer from "./components/Tabs/Transfer"
import Transactions from "./components/Tabs/Transactions"
import {useQuery} from "@tanstack/react-query"
import {getBalances, getTransactions} from "@client/utils/query"
import {utils} from "ethers"

export default function Home() {
    const store = useStore(useMageStore, (state) => state)
    const {data: session, status} = useSession()
    const loading = status === "loading"

    const {
        data: balances,
        isFetching: bFetching,
        isError: bError,
        isSuccess: bSuccess,
    } = useQuery({
        queryKey: ["balances"],
        queryFn: () => getBalances(store?.safe),
    })

    const {
        data: transactions,
        isFetching: tFetching,
        isError: tError,
        isSuccess: tSuccess,
    } = useQuery({
        queryKey: ["transactions"],
        queryFn: () => getTransactions(store?.safe),
    })

    const renderActiveTab = () => {
        switch (store?.activeTab) {
            case "transactions":
                return loading || tFetching ? <Table /> : <Transactions tx={transactions} />
            default:
                return loading || bFetching ? (
                    <Table />
                ) : (
                    <Overview balances={balances?.balances} total={balances?.total}>
                        <Transfer
                            balances={balances?.balances?.map((token, i) => {
                                return {
                                    label: token.symbol,
                                    value: i,
                                    address: token.address,
                                    balance: parseFloat(utils.formatEther(token.balance)),
                                }
                            })}
                        />
                    </Overview>
                )
        }
    }

    if (!store?.connected) return <Disconnected />
    return <div className="h-[75vh]">{renderActiveTab()}</div>
}
