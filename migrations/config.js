const zeroAddress = "0x0000000000000000000000000000000000000000"
const chainSymbol = "BNB"
//TODO
const chains = {
    dev: {
        node:    "http://192.168.1.64:8545",
        browser: "http://localhost:8545",
        swapURL: "#",
        chainName: "Devnet",
        symbol:  chainSymbol,
        symbolDecimals: 18,
        knownContracts: {
            USDT: "",
        }
    },
}

const ckeys = {
    USDC: "USDC",
    BTC: "BTC",
    ETH: "ETH",
    Satori: "Satori",
    Oracle: "Oracle"
}

const otherKeys = [
    ckeys.Satori,
    ckeys.Oracle,
]

const tokenKeys = [
    ckeys.USDC,
    ckeys.BTC,
    ckeys.ETH,
]

module.exports = {
    chains,
    zeroAddress,

    otherKeys,
    tokenKeys,

    ckeys, 
}