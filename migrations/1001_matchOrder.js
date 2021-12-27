const BigNumber = require('bignumber.js');

const { getContract } = require('./cache')
const { ckeys, zeroAddress } = require('./config')

const addLeadingZero = (str, length) => {
    let len = str.length;
    return '0'.repeat(length - len) + str;
};

const addTailingZero = (str, length) => {
    let len = str.length;
    return str + '0'.repeat(length - len);
};

const generateOrderData = (
    version,
    isSell,
    isMarket,
    expiredAtSeconds,
    asMakerFeeRate,
    asTakerFeeRate,
    makerRebateRate,
    salt,
    isMakerOnly,
    balancePath
) => {
    let res = '0x';
    res += addLeadingZero(new BigNumber(version).toString(16), 2);
    res += isSell ? '01' : '00';
    res += isMarket ? '01' : '00';
    res += addLeadingZero(new BigNumber(expiredAtSeconds).toString(16), 5 * 2);
    res += addLeadingZero(new BigNumber(asMakerFeeRate).toString(16), 2 * 2);
    res += addLeadingZero(new BigNumber(asTakerFeeRate).toString(16), 2 * 2);
    res += addLeadingZero(new BigNumber(makerRebateRate).toString(16), 2 * 2);
    res += addLeadingZero(new BigNumber(salt).toString(16), 8 * 2);
    res += isMakerOnly ? '01' : '00';

    if (balancePath) {
        res += '01' + addLeadingZero(new BigNumber(balancePath.marketID).toString(16), 2 * 2);
    } else {
        res += '000000';
    }

    return addTailingZero(res, 66);
};

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
    const takerOrder = {
        trader: taker,
        baseAssetAmount: "100",
        quoteAssetAmount: "20",
        collateral: "66",
        data: generateOrderData(1, true, false, 0, 1, 1, 0, 1, false),
    }

    const makerOrders = [{
        trader: maker1,
        baseAssetAmount: "10",
        quoteAssetAmount: "30",
        collateral: "99",
        data: generateOrderData(1, false, false, 0, 1, 1, 0, 1, false),
    }]

    await satori.matchOrders({
        takerOrderParam:  takerOrder,
        makerOrderParams: makerOrders,
        orderAddressSet: {
            baseAsset: btc.address,
            quoteAsset: usdc.address,
        }
    })
}

module.exports = async (deployer, network, accounts) => {
    await testBalance(accounts[0], "u0")
    await testBalance(accounts[1], "u1")
    await testCollateralBalance(accounts[0], "u0")
    await testCollateralBalance(accounts[1], "u1")

    await testDeposit(accounts[0], "200")
    await testDeposit(accounts[1], "100")

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

