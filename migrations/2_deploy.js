const ERC20Token = artifacts.require('ERC20Token')
const Satori = artifacts.require('Satori')
const Oracle = artifacts.require('Oracle')

const { saveContract } = require('./cache')
const { ckeys } = require('./config')

module.exports = async (deployer, network, accounts) => {
    await deployer.deploy(ERC20Token, "USD Coin", "USDC", 8, "10000000")
    const usdc = await ERC20Token.deployed()
    saveContract(ckeys.USDC, usdc)

    const amount = "10000"
    await usdc.transfer(accounts[1], amount)
    await usdc.transfer(accounts[2], amount)

    await deployer.deploy(ERC20Token, "ETH", "ETH", 18, "10000000")
    const eth = await ERC20Token.deployed()
    saveContract(ckeys.ETH, eth)

    await deployer.deploy(ERC20Token, "BTC", "BTC", 18, "10000000")
    const btc = await ERC20Token.deployed()
    saveContract(ckeys.BTC, btc)

    await deployer.deploy(Oracle, accounts[1])
    const oracle = await Oracle.deployed()
    saveContract(ckeys.Oracle, oracle)

    const tokens = [
        accounts[0],
        accounts[1],
    ]

    const prices = [
        "123456",
        "123458",
    ]

    let price = await oracle.getPrice(accounts[0]);
    console.log("1 price:", price.toString())

    await oracle.updatePrices(tokens, prices, {from: accounts[1]})

    price = await oracle.getPrice(accounts[0]);
    console.log("2 price:", price.toString())

    await deployer.deploy(Satori, usdc.address)
    const satori = await Satori.deployed()
    saveContract(ckeys.Satori, satori)
};
