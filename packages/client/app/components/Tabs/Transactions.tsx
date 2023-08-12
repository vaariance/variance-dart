import React from "react"
import {formatAddress} from "@client/utils/address"
import Empty from "../Skeletons/Empty"
import {ITransaction} from "@client/utils/query"
import {utils} from "ethers"

const Transactions = ({tx}: {tx?: ITransaction[]}) => {
    if (tx?.length === 0) {
        return <Empty />
    }
    return (
        <div className="max-w-screen-xl mx-auto px-4 p-10">
            <div className="max-w-lg">
                <h3 className="text-gray-800 text-xl font-bold sm:text-2xl">Transactions</h3>
            </div>
            <div className="mt-12 shadow-sm rounded-lg overflow-x-auto">
                <table className="w-full table-auto text-sm text-left">
                    <thead className="bg-gray-50 text-gray-600 font-medium border-b">
                        <tr>
                            <th className="py-3 px-6">Hash</th>
                            <th className="py-3 px-6">From</th>
                            <th className="py-3 px-6">To</th>
                            <th className="py-3 px-6">Fees</th>
                            <th className="py-3 px-6"></th>
                            <th className="py-3 px-6">Date</th>
                        </tr>
                    </thead>
                    <tbody className="text-gray-600 divide-y">
                        {tx?.map((item, idx) => (
                            <tr key={idx}>
                                <td className="px-6 py-4 whitespace-nowrap">
                                    <a
                                        href={`https://goerli-optimism.etherscan.io/tx/${item.tx_hash}`}
                                        target="_blank"
                                        className="text-blue-500 underline"
                                    >
                                        {formatAddress(item.tx_hash)}
                                    </a>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap">{formatAddress(item.from)}</td>
                                <td className="px-6 py-4 whitespace-nowrap">{formatAddress(item.to)}</td>
                                <td className="px-6 py-4 whitespace-nowrap">
                                    {parseFloat(utils.formatEther(item.fees)).toFixed(5)} ETH
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap">
                                    <span className="bg-blue-100 text-blue-800 text-sm font-medium mr-2 px-2.5 py-0.5 rounded">
                                        ${item.quote.toFixed(3)}
                                    </span>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap">{item.tx_date}</td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    )
}

export default Transactions
