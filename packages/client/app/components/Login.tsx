"use client"
import Image from "next/image"
import {signIn} from "next-auth/react"

const Login = () => {
    return (
        <div className="max-w-sm w-full text-gray-600 space-y-8">
            <div className="text-center">
                <Image src="/wld.png" width={65} height={65} alt="id wallet logo" className="mx-auto" />
                <div className="mt-5 space-y-2">
                    <h3 className="text-gray-800 text-2xl font-bold sm:text-3xl">Log in with World ID</h3>
                    <p className="">
                        Don&lsquo;t have a World ID?{" "}
                        <a
                            href="https://worldcoin.org/download"
                            target="_blank"
                            className="font-medium text-teal-600 hover:text-teal-500"
                        >
                            create now
                        </a>
                    </p>
                </div>
            </div>
            <a
                href={`/api/auth/signin`}
                className="flex items-center justify-center gap-2 px-4 py-2 text-gray-600 bg-gray-200 rounded-lg duration-150 hover:bg-gray-100 active:bg-gray-200 w-full font-medium"
                onClick={(e) => {
                    e.preventDefault()
                    signIn("worldcoin")
                }}
            >
                <Image src="/wld.png" width={35} height={35} alt="id wallet logo" />
                World App
            </a>
            <div className="text-center">
                <a href="https://docs.worldcoin.org/" target="_blank" className="text-teal-600 hover:text-teal-500">
                    don&lsquo;t know how to connect?
                </a>
            </div>
        </div>
    )
}

export default Login
