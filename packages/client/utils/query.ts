import axios from "axios"

const BASE_URL = "https://api.covalenthq.com/v1/base-testnet/address/"
const CKEY = process.env.NEXT_PUBLIC_CKEY || ""

export interface IBalance {
    decimals: number
    name: string
    symbol: string
    address: string
    logo: string
    balance: number
    quote_rate: number
    quote: number
    native: boolean
}

export interface IBalanceT {
    balances?: IBalance[]
    total?: number
}

export const getBalances = async (address?: string) => {
    try {
        const data = await axios
            .get(`${BASE_URL}${address}/balances_v2/?key=${CKEY}&no-nft-fetch=true&no-spam=true`)
            .then((res) => {
                return res.data.data.items
            })
            .catch((err) => console.log(err))

        const formattedData: IBalanceT = data.slice(0, 20).reduce(
            (acc: {balances: IBalance[]; total: number}, item: any) => {
                acc.balances.push({
                    decimals: item.contract_decimals,
                    name: item.contract_name,
                    symbol: item.contract_ticker_symbol,
                    address: item.contract_address,
                    logo: item.logo_url,
                    balance: item.balance,
                    quote_rate: item.quote_rate,
                    quote: item.quote,
                    native: item.native_token,
                })
                acc.total += item.quote
                return acc
            },
            {balances: [], total: 0} as IBalanceT
        )
        return formattedData
    } catch (error) {
        return {balances: [], total: 0}
    }
}

export interface ITransaction {
    tx_date: string
    tx_hash: string
    from: string
    to: string
    fees: number
    quote: number
}

export const getTransactions = async (address?: string) => {
    try {
        const data = await axios
            .get(`${BASE_URL}${address}/transactions_v3/page/0/?key=${CKEY}&no-logs=true`)
            .then((res) => res.data.data.items)
            .catch((err) => console.log(err))

        const formattedData: ITransaction[] = data.slice(0, 20).reduce((acc: ITransaction[], item: any) => {
            const txDate = new Date(item.block_signed_at).getTime() // Convert to milliseconds since epoch
            const now = new Date().getTime()
            const timeDifference = now - txDate

            let formattedTxDate

            if (timeDifference >= 2592000000) {
                const monthsAgo = Math.floor(timeDifference / 2592000000)
                formattedTxDate = `${monthsAgo} ${monthsAgo === 1 ? "month" : "months"} ago`
            } else if (timeDifference >= 86400000) {
                const daysAgo = Math.floor(timeDifference / 86400000)
                formattedTxDate = `${daysAgo} ${daysAgo === 1 ? "day" : "days"} ago`
            } else if (timeDifference >= 3600000) {
                const hoursAgo = Math.floor(timeDifference / 3600000)
                formattedTxDate = `${hoursAgo} ${hoursAgo === 1 ? "hour" : "hours"} ago`
            } else if (timeDifference >= 60000) {
                const minutesAgo = Math.floor(timeDifference / 60000)
                formattedTxDate = `${minutesAgo} ${minutesAgo === 1 ? "minute" : "minutes"} ago`
            } else {
                formattedTxDate = "Just now"
            }

            acc.push({
                tx_date: formattedTxDate,
                tx_hash: item.tx_hash,
                from: item.from_address,
                to: item.to_address,
                fees: item.fees_paid,
                quote: item.gas_quote,
            })
            return acc
        }, [] as ITransaction[])

        return formattedData
    } catch (error) {
        return []
    }
}
