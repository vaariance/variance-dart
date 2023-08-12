import {useMageStore, useStore} from "@client/store"
import Image from "next/image"

const Empty = () => {
    const state = useStore(useMageStore, (state) => state)
    return (
        <section className="py-4 overflow-hidden max-w-screen-xl h-[75vh] mx-auto p-10">
            <div className="container px-4 flex justify-center items-center h-full bg-neutral-50">
                <div className="max-w-md m-auto text-center">
                    <Image className="m-auto" src="/empty.jpeg" alt="" width={75} height={75} />
                    <h2 className="font-heading mb-3 text-2xl font-semibold">It&rsquo;s a bit empty here</h2>
                    <p className="mb-7 text-neutral-500">Click on the Button below to create your Safe Wallet.</p>
                    <button
                        className="inline-flex items-center gap-2 px-4 py-2 text-indigo-600 bg-indigo-50 rounded-lg duration-150 hover:bg-indigo-100 active:bg-indigo-200"
                        onClick={() => state?.setActiveTab("overview")}
                    >
                        <svg
                            xmlns="http://www.w3.org/2000/svg"
                            viewBox="0 0 24 24"
                            fill="currentColor"
                            className="w-5 h-5"
                        >
                            <path
                                fillRule="evenodd"
                                d="M12 5.25a.75.75 0 01.75.75v5.25H18a.75.75 0 010 1.5h-5.25V18a.75.75 0 01-1.5 0v-5.25H6a.75.75 0 010-1.5h5.25V6a.75.75 0 01.75-.75z"
                                clipRule="evenodd"
                            />
                        </svg>
                        Create Safe
                    </button>
                </div>
            </div>
        </section>
    )
}

export default Empty
