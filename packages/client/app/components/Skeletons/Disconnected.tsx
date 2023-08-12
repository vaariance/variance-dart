import Image from "next/image"
import Connect from "../Connect"

const Disconnected = () => {
    return (
        <section className="py-4 overflow-hidden max-w-screen-xl h-[75vh] mx-auto p-10">
            <div className="container px-4 flex justify-center items-center h-full bg-neutral-50">
                <div className="max-w-md m-auto text-center">
                    <Image
                        className="m-auto animate-pulse"
                        src="/no-wifi.png"
                        alt="https://www.flaticon.com"
                        width={75}
                        height={75}
                    />
                    <h2 className="font-heading mb-3 text-2xl font-semibold">Trying to reach your wallet</h2>
                    <p className="mb-7 text-neutral-500">
                        Sign In with World ID first to access the app. If you don&lsquo;t have an account, you can
                        download the World App{" "}
                        <a className="text-blue-500 underline" href="https://worldcoin.org/download">
                            here
                        </a>
                    </p>
                    <Connect />
                </div>
            </div>
        </section>
    )
}

export default Disconnected
