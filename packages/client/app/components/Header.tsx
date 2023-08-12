"use client"
import {useEffect, useState} from "react"
import {useMageStore, useStore} from "@client/store"
import Connect from "./Connect"
import Blockies from "react-blockies"
import {formatAddress} from "@client/utils/address"
import Image from "next/image"

const Header = () => {
    const [state, setState] = useState(false)
    const [address, setAddress] = useState("")
    const store = useStore(useMageStore, (state) => state)

    const submenuNav = [
        {title: "Overview", path: () => store?.setActiveTab("overview")},
        {title: "Send", path: () => store?.setActiveTab("send")},
        {title: "Transactions", path: () => store?.setActiveTab("transactions")},
    ]
    // const getAddress = async () => {
    //     if (store?.connected) return await window.arweaveWallet.getActiveAddress()
    //     return ""
    // }

    // useEffect(() => {
    //     getAddress().then((address) => {
    //         setAddress(address)
    //     })
    // }, [store?.connected])

    const logout = async () => {
        console.log("logout")
    }

    return (
        <header className="text-base lg:text-sm">
            <div
                className={`bg-white items-center gap-x-14 px-4 max-w-screen-xl mx-auto lg:flex lg:px-8 lg:static ${
                    state ? "h-full fixed inset-x-0" : ""
                }`}
            >
                <div className="flex items-center justify-between py-3 lg:py-5 lg:block">
                    <a href="/app">
                        <Image src="/arMage.png" width={35} height={35} alt="arMage logo" />
                    </a>
                    <div className="lg:hidden">
                        <button className="text-gray-500 hover:text-gray-800" onClick={() => setState(!state)}>
                            {state ? (
                                <svg
                                    xmlns="http://www.w3.org/2000/svg"
                                    className="h-6 w-6"
                                    viewBox="0 0 20 20"
                                    fill="currentColor"
                                >
                                    <path
                                        fillRule="evenodd"
                                        d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
                                        clipRule="evenodd"
                                    />
                                </svg>
                            ) : (
                                <svg
                                    xmlns="http://www.w3.org/2000/svg"
                                    viewBox="0 0 24 24"
                                    fill="currentColor"
                                    className="w-6 h-6"
                                >
                                    <path
                                        fillRule="evenodd"
                                        d="M3 6.75A.75.75 0 013.75 6h16.5a.75.75 0 010 1.5H3.75A.75.75 0 013 6.75zM3 12a.75.75 0 01.75-.75h16.5a.75.75 0 010 1.5H3.75A.75.75 0 013 12zm8.25 5.25a.75.75 0 01.75-.75h8.25a.75.75 0 010 1.5H12a.75.75 0 01-.75-.75z"
                                        clipRule="evenodd"
                                    />
                                </svg>
                            )}
                        </button>
                    </div>
                </div>
                <div
                    className={`nav-menu flex-1 pb-28 mt-8 overflow-y-auto max-h-screen lg:block lg:overflow-visible lg:pb-0 lg:mt-0 ${
                        state ? "" : "hidden"
                    }`}
                >
                    <ul className="items-center space-y-6 lg:flex lg:space-x-6 lg:space-y-0">
                        <form
                            onSubmit={(e) => e.preventDefault()}
                            className="flex-1 items-center justify-start pb-4 lg:flex lg:pb-0"
                        >
                            <div className="flex items-center gap-1 px-2 border rounded-lg">
                                <svg
                                    xmlns="http://www.w3.org/2000/svg"
                                    className="w-6 h-6 text-gray-400"
                                    fill="none"
                                    viewBox="0 0 24 24"
                                    stroke="currentColor"
                                >
                                    <path
                                        strokeLinecap="round"
                                        strokeLinejoin="round"
                                        strokeWidth={2}
                                        d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                                    />
                                </svg>
                                <input
                                    type="text"
                                    placeholder="Search"
                                    className="w-full px-2 py-2 text-gray-500 bg-transparent rounded-md outline-none"
                                />
                            </div>
                        </form>

                        {store?.connected ? (
                            <ul className="items-center space-y-6 lg:flex lg:space-x-6 lg:space-y-0">
                                <li>
                                    <button
                                        onClick={() => logout()}
                                        className="block w-full text-justify text-gray-600 hover:text-gray-900 border-b py-3 lg:hover:bg-gray-50 lg:p-3"
                                    >
                                        Logout
                                    </button>
                                </li>
                                <li className="">
                                    <button
                                        className="opacity-80 inline-flex text-gray-600 border-teal-600 hover:text-teal-900 border-b py-3 lg:hover:bg-gray-50 lg:p-3 font-medium"
                                        onClick={() => navigator.clipboard.writeText(address)}
                                    >
                                        {formatAddress(address)}
                                        <span>
                                            <svg
                                                fill="none"
                                                stroke="currentColor"
                                                strokeWidth="1.5"
                                                viewBox="0 0 24 24"
                                                xmlns="http://www.w3.org/2000/svg"
                                                aria-hidden="true"
                                                className="w-5 h-5 text-gray-600 hover:text-gray-900 pl-2"
                                            >
                                                <path
                                                    strokeLinecap="round"
                                                    strokeLinejoin="round"
                                                    d="M8.25 7.5V6.108c0-1.135.845-2.098 1.976-2.192.373-.03.748-.057 1.123-.08M15.75 18H18a2.25 2.25 0 002.25-2.25V6.108c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 00-1.123-.08M15.75 18.75v-1.875a3.375 3.375 0 00-3.375-3.375h-1.5a1.125 1.125 0 01-1.125-1.125v-1.5A3.375 3.375 0 006.375 7.5H5.25m11.9-3.664A2.251 2.251 0 0015 2.25h-1.5a2.251 2.251 0 00-2.15 1.586m5.8 0c.065.21.1.433.1.664v.75h-6V4.5c0-.231.035-.454.1-.664M6.75 7.5H4.875c-.621 0-1.125.504-1.125 1.125v12c0 .621.504 1.125 1.125 1.125h9.75c.621 0 1.125-.504 1.125-1.125V16.5a9 9 0 00-9-9z"
                                                ></path>
                                            </svg>
                                        </span>
                                    </button>
                                </li>
                                <li className="hidden w-10 h-10 outline-none rounded-full ring-offset-2 ring-gray-200 lg:focus:ring-2 lg:block">
                                    <Blockies seed={address} size={10} scale={3} className="rounded-full" />
                                </li>
                            </ul>
                        ) : (
                            <Connect />
                        )}
                    </ul>
                </div>
            </div>
            <nav className="border-b mt-5">
                <ul className="flex max-w-screen-xl mx-auto items-center gap-x-3 px-4 overflow-x-auto lg:px-8">
                    {submenuNav.map((item, idx) => {
                        return (
                            <li
                                key={idx}
                                className={`py-1 ${
                                    store?.activeTab == item.title.toLowerCase() ? "border-b-2 border-teal-600" : ""
                                }`}
                            >
                                <a
                                    onClick={item.path}
                                    className="block py-2 px-3 rounded-lg text-gray-700 hover:text-gray-900 hover:bg-gray-100 duration-150"
                                >
                                    {item.title}
                                </a>
                            </li>
                        )
                    })}
                </ul>
            </nav>
        </header>
    )
}

export default Header
