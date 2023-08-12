import React from "react"
import {formatAddress} from "@client/utils/address"
import Empty from "../Skeletons/Empty"

const Transactions = ({tx}: {tx?: any[]}) => {
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
                            <th className="py-3 px-6">Address</th>
                            <th className="py-3 px-6">txId</th>
                            <th className="py-3 px-6">Url</th>
                            <th className="py-3 px-6">Type</th>
                            <th className="py-3 px-6">Cost</th>
                        </tr>
                    </thead>
                    <tbody className="text-gray-600 divide-y">
                        {tx?.map((item, idx) => (
                            <tr key={idx}>
                                <td className="px-6 py-4 whitespace-nowrap">
                                    {formatAddress(item?.node?.owner?.address)}
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap">{formatAddress(item?.node?.id)}</td>
                                <td className="px-6 py-4 whitespace-nowrap">
                                    <a
                                        href={`https://viewblock.io/arweave/tx/${item?.node?.id}`}
                                        target="_blank"
                                        className="text-blue-500 underline"
                                    >
                                        link
                                    </a>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap">{item?.node?.data?.type.split("/")[0]}</td>
                                <td className="px-6 py-4 whitespace-nowrap">
                                    {parseFloat(item?.node?.fee?.ar).toFixed(7)} AR
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
        </div>
    )
}

export default Transactions
