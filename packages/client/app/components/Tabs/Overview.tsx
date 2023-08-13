"use client"
import {useMageStore, useStore} from "@client/store"
import {formatAddress} from "@client/utils/address"
import {IBalanceT} from "@client/utils/query"
import {utils} from "ethers"
import {PropsWithChildren, useState} from "react"
import QRCode from "react-qr-code"
import Modal from "../Modal"

const Overview = ({balances, total, children}: PropsWithChildren<IBalanceT>) => {
    const [openConnectModal, setOpenConnectModal] = useState(false)
    const [broken, setBroken] = useState<{[key: string]: string}>({})

    const safe = useStore(useMageStore, (state) => state.safe)

    return (
        <div className="max-w-screen-xl mx-auto p-10 grid grid-cols-1 md:grid-cols-3 gap-5 ">
            <div className="space-y-5 col-span-2 mx-auto max-w-2xl w-full">
                <div className="border rounded-lg bg-gradient-to-r from-teal-50 to-teal-100">
                    <div className="flex items-start justify-between p-4">
                        <div className="space-y-2">
                            <svg
                                className="w-10 h-10"
                                width="111"
                                height="111"
                                viewBox="0 0 111 111"
                                fill="none"
                                xmlns="http://www.w3.org/2000/svg"
                            >
                                <path
                                    d="M54.921 110.034C85.359 110.034 110.034 85.402 110.034 55.017C110.034 24.6319 85.359 0 54.921 0C26.0432 0 2.35281 22.1714 0 50.3923H72.8467V59.6416H3.9565e-07C2.35281 87.8625 26.0432 110.034 54.921 110.034Z"
                                    fill="#0052FF"
                                />
                            </svg>
                            <h4 className="text-gray-800 font-bold text-3xl">${total?.toFixed(4)}</h4>
                            <button
                                className="text-gray-600 font-semibold inline-flex items-center"
                                onClick={() => navigator.clipboard.writeText(safe || "")}
                            >
                                {formatAddress(safe || "")}
                                <span>
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
                            </button>
                        </div>
                        <Modal state={openConnectModal} setState={setOpenConnectModal}>
                            <div className="h-auto pt-5 pb-12 m-auto max-w-xs w-full rounded-2xl">
                                <QRCode
                                    size={256}
                                    style={{height: "auto", maxWidth: "100%", width: "100%"}}
                                    value={safe || "random extropy"}
                                    viewBox={`0 0 256 256`}
                                />
                            </div>
                        </Modal>
                        <button
                            className="hover:text-white text-gray-600 text-sm border rounded-lg p-1 duration-150 bg-gray-200 hover:bg-transparent"
                            onClick={() => setOpenConnectModal(true)}
                        >
                            <svg
                                fill="currentColor"
                                viewBox="0 0 24 24"
                                className="w-6 h-6"
                                xmlns="http://www.w3.org/2000/svg"
                                aria-hidden="true"
                            >
                                <path
                                    clipRule="evenodd"
                                    fillRule="evenodd"
                                    d="M3 4.875C3 3.839 3.84 3 4.875 3h4.5c1.036 0 1.875.84 1.875 1.875v4.5c0 1.036-.84 1.875-1.875 1.875h-4.5A1.875 1.875 0 013 9.375v-4.5zM4.875 4.5a.375.375 0 00-.375.375v4.5c0 .207.168.375.375.375h4.5a.375.375 0 00.375-.375v-4.5a.375.375 0 00-.375-.375h-4.5zm7.875.375c0-1.036.84-1.875 1.875-1.875h4.5C20.16 3 21 3.84 21 4.875v4.5c0 1.036-.84 1.875-1.875 1.875h-4.5a1.875 1.875 0 01-1.875-1.875v-4.5zm1.875-.375a.375.375 0 00-.375.375v4.5c0 .207.168.375.375.375h4.5a.375.375 0 00.375-.375v-4.5a.375.375 0 00-.375-.375h-4.5zM6 6.75A.75.75 0 016.75 6h.75a.75.75 0 01.75.75v.75a.75.75 0 01-.75.75h-.75A.75.75 0 016 7.5v-.75zm9.75 0A.75.75 0 0116.5 6h.75a.75.75 0 01.75.75v.75a.75.75 0 01-.75.75h-.75a.75.75 0 01-.75-.75v-.75zM3 14.625c0-1.036.84-1.875 1.875-1.875h4.5c1.036 0 1.875.84 1.875 1.875v4.5c0 1.035-.84 1.875-1.875 1.875h-4.5A1.875 1.875 0 013 19.125v-4.5zm1.875-.375a.375.375 0 00-.375.375v4.5c0 .207.168.375.375.375h4.5a.375.375 0 00.375-.375v-4.5a.375.375 0 00-.375-.375h-4.5zm7.875-.75a.75.75 0 01.75-.75h.75a.75.75 0 01.75.75v.75a.75.75 0 01-.75.75h-.75a.75.75 0 01-.75-.75v-.75zm6 0a.75.75 0 01.75-.75h.75a.75.75 0 01.75.75v.75a.75.75 0 01-.75.75h-.75a.75.75 0 01-.75-.75v-.75zM6 16.5a.75.75 0 01.75-.75h.75a.75.75 0 01.75.75v.75a.75.75 0 01-.75.75h-.75a.75.75 0 01-.75-.75v-.75zm9.75 0a.75.75 0 01.75-.75h.75a.75.75 0 01.75.75v.75a.75.75 0 01-.75.75h-.75a.75.75 0 01-.75-.75v-.75zm-3 3a.75.75 0 01.75-.75h.75a.75.75 0 01.75.75v.75a.75.75 0 01-.75.75h-.75a.75.75 0 01-.75-.75v-.75zm6 0a.75.75 0 01.75-.75h.75a.75.75 0 01.75.75v.75a.75.75 0 01-.75.75h-.75a.75.75 0 01-.75-.75v-.75z"
                                />
                            </svg>
                        </button>
                    </div>
                    <div className="py-5 px-4 border-t text-right">
                        <a href="#" className="text-teal-800 hover:text-teal-700 text-sm font-medium underline">
                            View on block explorer
                        </a>
                    </div>
                </div>
                <div>
                    <h4 className="text-gray-800 text-xl font-semibold">Balances</h4>
                </div>
                <ul className="mt-12 divide-y max-h-screen overflow-y-auto">
                    {balances?.map((item, idx) => (
                        <li key={idx} className="py-5 flex items-start justify-between">
                            <div className="flex gap-3">
                                <img
                                    src={broken[item.logo] ? broken[item.logo] : item.logo}
                                    width={24}
                                    height={24}
                                    alt={item.name}
                                    className="flex-none w-12 h-12 rounded-full"
                                    onError={() =>
                                        setBroken({
                                            ...broken,
                                            [item.logo]: "/broken.png",
                                        })
                                    }
                                />
                                <div>
                                    <span className="block text-sm text-gray-700 font-semibold">{item.symbol}</span>
                                    <span className="block text-sm text-gray-600">{item.name}</span>
                                </div>
                            </div>
                            <div>
                                <span className="block text-sm text-gray-700 font-semibold">
                                    {parseFloat(utils.formatEther(item.balance)).toFixed(3)}
                                </span>
                                <span className="block text-sm text-gray-600">${item.quote.toFixed(2)}</span>
                            </div>
                        </li>
                    ))}
                </ul>
            </div>
            {children}
        </div>
    )
}

export default Overview
