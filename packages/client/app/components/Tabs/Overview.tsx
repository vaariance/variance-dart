"use client"
import Empty from "../Skeletons/Empty"

const Overview = ({accounts}: {accounts?: any[]}) => {
    const handleCopyLink = (text: string) => {
        navigator.clipboard.writeText(text)
    }

    if (accounts?.length === 0) {
        return <Empty />
    }

    return (
        <div className="columns-1 gap-5 md:columns-2 lg:columns-4 max-w-screen-xl mx-auto p-10">overview goes here</div>
    )
}

export default Overview
