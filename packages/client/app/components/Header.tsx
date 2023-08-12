"use client"
import {useMageStore, useStore} from "@client/store"
import {useSession, signOut} from "next-auth/react"
import Image from "next/image"
import {useState} from "react"
import Connect from "./Connect"

const Header = () => {
    const [state, setState] = useState(false)
    const store = useStore(useMageStore, (state) => state)
    const {data: session} = useSession()

    const submenuNav = [
        {title: "Overview", path: () => store?.setActiveTab("overview")},
        {title: "Transfer", path: () => store?.setActiveTab("transfer")},
        {title: "Transactions", path: () => store?.setActiveTab("transactions")},
    ]

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
                    <ul className="items-center justify-end space-y-6 lg:flex lg:space-x-6 lg:space-y-0">
                        {session?.user ? (
                            <ul className="items-center space-y-6 lg:flex lg:space-x-6 lg:space-y-0">
                                <li>
                                    <a
                                        href={`/api/auth/signout`}
                                        onClick={(e) => {
                                            e.preventDefault()
                                            signOut()
                                        }}
                                        className="block w-full text-justify text-gray-600 hover:text-gray-900 border-b py-3 lg:hover:bg-gray-50 lg:p-3"
                                    >
                                        Logout
                                    </a>
                                </li>
                                <li className="">
                                    <button className="opacity-80 inline-flex text-gray-600 border-teal-600 hover:text-teal-900 border-b py-3 lg:hover:bg-gray-50 lg:p-3 font-medium">
                                        {session.user.email ?? session.user.name}
                                    </button>
                                </li>
                                <li className="hidden w-10 h-10 outline-none rounded-full ring-offset-2 ring-gray-200 lg:focus:ring-2 lg:block">
                                    {session.user.image && (
                                        <Image
                                            src={session.user.image}
                                            width={20}
                                            height={20}
                                            alt="user image"
                                            className="rounded-full"
                                        />
                                    )}
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
