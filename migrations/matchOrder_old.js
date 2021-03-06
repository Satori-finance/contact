const BigNumber = require('bignumber.js');

const { getContract } = require('./cache')
const { ckeys, zeroAddress } = require('./config');
const { generateOrderData } = require('./utils');

async function testBalance(account, prefix) {
    const usdc = getContract(ckeys.USDC)
    let balanace = await usdc.balanceOf(account)
    console.log(`${prefix}=>balanace: ${balanace.toString()}`)
}

async function testCollateralBalance(account, prefix) {
    const satori = getContract(ckeys.Satori)
    let balanace = await satori.getCollateralBalance(account)
    console.log(`${prefix}=>collateral balance: ${balanace.toString()}`)
}

async function testDeposit(account, amount) {
    const satori = getContract(ckeys.Satori)
    const usdc = getContract(ckeys.USDC)

    await usdc.approve(satori.address, amount, {from: account})
    await satori.deposit(amount, {from: account})
    console.log("deposit done")
}

async function testMatch(accounts) {
    const satori = getContract(ckeys.Satori)
    const btc = getContract(ckeys.BTC)
    const usdc = getContract(ckeys.USDC)

    const taker = accounts[0]
    const maker1 = accounts[1]
    const maker2 = accounts[2]

    //sell
    const takerOrder = {
        trader: taker,
        baseAssetAmount: "100",
        quoteAssetAmount: "20",
        collateral: "10",
        data: generateOrderData({
            version: 1,
            isSell: true,
            isMarket: false,
            isMakerOnly: false,
            marketId: 0,
            salt: 1
        }),
    }

    
    //buy
    const makerOrder1 = {
        trader: maker1,
        baseAssetAmount: "10",
        quoteAssetAmount: "30",
        collateral: "12",
        data: generateOrderData({
            version: 1,
            isSell: false,
            isMarket: false,
            isMakerOnly: false,
            marketId: 0,
            salt: 1
        }),
    }
    
    const makerOrder2 = {
        trader: maker2,
        baseAssetAmount: "20",
        quoteAssetAmount: "25",
        collateral: "120",
        data: generateOrderData({
            version: 1,
            isSell: false,
            isMarket: false,
            isMakerOnly: false,
            marketId: 0,
            salt: 1
        }),
    }

    const makerOrders = [
        makerOrder1,
        makerOrder2,
    ]

    await satori.matchOrders({
        takerOrderParam:  takerOrder,
        makerOrderParams: makerOrders,
    })
}

async function testClose(accounts) {

}

async function testCreateMarket() {
    const satori = getContract(ckeys.Satori)
    const btc = getContract(ckeys.BTC)
    const usdc = getContract(ckeys.USDC)

    await satori.createMarket({
        baseAsset: btc.address,
        quoteAsset: usdc.address,
    })
}


module.exports = async (deployer, network, accounts) => {
    await testCreateMarket()

    await testBalance(accounts[0], "u0")
    await testBalance(accounts[1], "u1")
    await testCollateralBalance(accounts[0], "u0")
    await testCollateralBalance(accounts[1], "u1")

    await testDeposit(accounts[0], "200")
    await testDeposit(accounts[1], "100")
    await testDeposit(accounts[2], "1000")

    await testBalance(accounts[0], "u0")
    await testBalance(accounts[1], "u1")
    await testCollateralBalance(accounts[0], "u0")
    await testCollateralBalance(accounts[1], "u1")

    console.log("matching")
    await testMatch(accounts)
    console.log("match done")

    await testCollateralBalance(accounts[0], "u0")
    await testCollateralBalance(accounts[1], "u1")
}

