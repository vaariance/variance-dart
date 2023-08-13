"use client"
import {IBalanceT} from "@client/utils/query"
import Empty from "../Skeletons/Empty"
import {formatAddress} from "@client/utils/address"
import Image from "next/image"
import {utils} from "ethers"
import Modal from "../Modal"
import {PropsWithChildren, useState} from "react"
import QRCode from "react-qr-code"
import Transfer from "./Transfer"

const Overview = ({balances, total, children}: PropsWithChildren<IBalanceT>) => {
    const [openConnectModal, setOpenConnectModal] = useState(false)
    const [broken, setBroken] = useState<{[key: string]: string}>({})

    const handleCopyLink = (text: string) => {
        navigator.clipboard.writeText(text)
    }

    if (balances?.length === 0) {
        return <Empty />
    }

    return (
        <div className="max-w-screen-xl mx-auto p-10 grid grid-cols-1 md:grid-cols-3 gap-5 ">
            <div className="space-y-5 col-span-2 mx-auto max-w-2xl w-full">
                <div className="border rounded-lg bg-gradient-to-r from-teal-50 to-teal-100">
                    <div className="flex items-start justify-between p-4">
                        <div className="space-y-2">
                            <svg
                                className="w-10 h-10"
                                viewBox="0 0 50 50"
                                fill="none"
                                xmlns="http://www.w3.org/2000/svg"
                            >
                                <circle cx="25" cy="25" r="25" fill="white" />
                                <path
                                    fillRule="evenodd"
                                    clipRule="evenodd"
                                    d="M25 50C38.8071 50 50 38.8071 50 25C50 11.1929 38.8071 0 25 0C11.1929 0 0 11.1929 0 25C0 38.8071 11.1929 50 25 50ZM15.591 31.867C16.275 32.0823 17.016 32.19 17.814 32.19C19.6507 32.19 21.1137 31.7657 22.203 30.917C23.2923 30.0557 24.0523 28.7573 24.483 27.022C24.6097 26.4773 24.73 25.9327 24.844 25.388C24.9707 24.8433 25.0783 24.2923 25.167 23.735C25.319 22.8737 25.2937 22.12 25.091 21.474C24.901 20.828 24.5653 20.2833 24.084 19.84C23.6153 19.3967 23.039 19.0673 22.355 18.852C21.6837 18.624 20.949 18.51 20.151 18.51C18.3017 18.51 16.8323 18.9533 15.743 19.84C14.6537 20.7267 13.9 22.025 13.482 23.735C13.3553 24.2923 13.2287 24.8433 13.102 25.388C12.988 25.9327 12.8803 26.4773 12.779 27.022C12.6397 27.8833 12.665 28.637 12.855 29.283C13.0577 29.929 13.3933 30.4673 13.862 30.898C14.3307 31.3287 14.907 31.6517 15.591 31.867ZM19.866 28.846C19.3467 29.2513 18.745 29.454 18.061 29.454C17.3643 29.454 16.864 29.2513 16.56 28.846C16.256 28.4407 16.18 27.7947 16.332 26.908C16.4333 26.3507 16.5347 25.825 16.636 25.331C16.75 24.837 16.8767 24.324 17.016 23.792C17.2313 22.9053 17.5923 22.2593 18.099 21.854C18.6183 21.4487 19.22 21.246 19.904 21.246C20.588 21.246 21.0883 21.4487 21.405 21.854C21.7217 22.2593 21.7977 22.9053 21.633 23.792C21.5443 24.324 21.443 24.837 21.329 25.331C21.2277 25.825 21.1073 26.3507 20.968 26.908C20.7527 27.7947 20.3853 28.4407 19.866 28.846ZM25.6404 31.867C25.7164 31.9557 25.8177 32 25.9444 32H28.5284C28.6677 32 28.788 31.9557 28.8894 31.867C29.0034 31.7783 29.073 31.6643 29.0984 31.525L29.9724 27.364H32.5374C34.1714 27.364 35.4697 27.0157 36.4324 26.319C37.4077 25.6223 38.0537 24.5457 38.3704 23.089C38.5224 22.3543 38.516 21.7147 38.3514 21.17C38.1867 20.6127 37.8954 20.1503 37.4774 19.783C37.0594 19.4157 36.5337 19.1433 35.9004 18.966C35.2797 18.7887 34.583 18.7 33.8104 18.7H28.7564C28.6297 18.7 28.5094 18.7443 28.3954 18.833C28.2814 18.9217 28.2117 19.0357 28.1864 19.175L25.5644 31.525C25.539 31.6643 25.5644 31.7783 25.6404 31.867ZM32.6514 24.742H30.4664L31.2074 21.341H33.4874C33.9434 21.341 34.279 21.417 34.4944 21.569C34.7224 21.721 34.8554 21.9237 34.8934 22.177C34.9314 22.4303 34.9187 22.7217 34.8554 23.051C34.7287 23.621 34.4564 24.0453 34.0384 24.324C33.633 24.6027 33.1707 24.742 32.6514 24.742Z"
                                    fill="#FF0420"
                                />
                            </svg>
                            <h4 className="text-gray-800 font-bold text-3xl">${total?.toFixed(4)}</h4>
                            <button
                                className="text-gray-600 font-semibold inline-flex items-center"
                                onClick={() => navigator.clipboard.writeText(balances?.[0].address || "")}
                            >
                                {formatAddress(balances?.[0].address || "")}
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
                                    value={balances?.[0].address || "random extropy"}
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
