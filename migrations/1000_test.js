const { getContract } = require('./cache')
const { ckeys, zeroAddress } = require('./config')


async function testTokenDeposit(accounts) {
    const satori = getContract(ckeys.Satori)
    const usdt = getContract(ckeys.USDT)
    const user1 = accounts[0]

    const max = "1000000000000000000"
    await usdt.approve(satori.address, max)

    let satoriBalance = await usdt.balanceOf(satori.address)
    console.log("1-satoriBalance:", satoriBalance.toString())

    let balance = await usdt.balanceOf(user1)
    console.log("1-balance:", balance.toString())

    let deposit = await satori.getCommonBalance(usdt.address, user1)
    console.log("1-deposit:", deposit.toString())

    const amount = "10"
    await satori.deposit(usdt.address, amount)
    console.log("deposit done")

    deposit = await satori.getCommonBalance(usdt.address, user1)
    console.log("2-deposit:", deposit.toString())

    balance = await usdt.balanceOf(user1)
    console.log("2-balance:", balance.toString())

    satoriBalance = await usdt.balanceOf(satori.address)
    console.log("2-satoriBalance:", satoriBalance.toString())
}

async function testDeposit(accounts) {
    const satori = getContract(ckeys.Satori)
    const user1 = accounts[0]

    let ethSatoriBalance = await web3.eth.getBalance(satori.address)
    let balance = await web3.eth.getBalance(user1)
    console.log("1-satoriBalance:", ethSatoriBalance.toString())
    console.log("1-balance:", balance.toString())

    let deposit = await satori.getCommonBalance(zeroAddress, user1)
    console.log("1-deposit:", deposit.toString())

    const amount = "10"
    await satori.deposit(zeroAddress, 0, {value: amount})
    console.log("deposit done")

    deposit = await satori.getCommonBalance(zeroAddress, user1)
    console.log("2-deposit:", deposit.toString())

    ethSatoriBalance = await web3.eth.getBalance(satori.address)
    balance = await web3.eth.getBalance(user1)
    console.log("2-satoriBalance:", ethSatoriBalance.toString())
    console.log("2-balance:", balance.toString())
}

async function testTokenWithdraw(accounts) {
    const satori = getContract(ckeys.Satori)
    const usdt = getContract(ckeys.USDT)
    const user1 = accounts[0]

    const max = "1000000000000000000"
    await usdt.approve(satori.address, max)

    let satoriBalance = await usdt.balanceOf(satori.address)
    console.log("1-satoriBalance:", satoriBalance.toString())

    let balance = await usdt.balanceOf(user1)
    console.log("1-balance:", balance.toString())

    let deposit = await satori.getCommonBalance(usdt.address, user1)
    console.log("1-deposit:", deposit.toString())

    const amount1 = "10"
    await satori.deposit(usdt.address, amount1)
    console.log("deposit done")

    deposit = await satori.getCommonBalance(usdt.address, user1)
    console.log("2-deposit:", deposit.toString())

    balance = await usdt.balanceOf(user1)
    console.log("2-balance:", balance.toString())

    satoriBalance = await usdt.balanceOf(satori.address)
    console.log("2-satoriBalance:", satoriBalance.toString())

    const amount2 = "9"
    await satori.withdraw(usdt.address, amount2)
    console.log("withdraw done")

    deposit = await satori.getCommonBalance(usdt.address, user1)
    console.log("3-deposit:", deposit.toString())

    balance = await usdt.balanceOf(user1)
    console.log("3-balance:", balance.toString())

    satoriBalance = await usdt.balanceOf(satori.address)
    console.log("3-satoriBalance:", satoriBalance.toString())
}

async function testWithdraw(accounts) {
    const satori = getContract(ckeys.Satori)
    const user1 = accounts[0]

    let ethSatoriBalance = await web3.eth.getBalance(satori.address)
    let balance = await web3.eth.getBalance(user1)
    console.log("1-satoriBalance:", ethSatoriBalance.toString())
    console.log("1-balance:", balance.toString())

    let deposit = await satori.getCommonBalance(zeroAddress, user1)
    console.log("1-deposit:", deposit.toString())

    const amount1 = "10"
    await satori.deposit(zeroAddress, 0, {value: amount1})
    console.log("deposit done")

    deposit = await satori.getCommonBalance(zeroAddress, user1)
    console.log("2-deposit:", deposit.toString())

    ethSatoriBalance = await web3.eth.getBalance(satori.address)
    balance = await web3.eth.getBalance(user1)
    console.log("2-satoriBalance:", ethSatoriBalance.toString())
    console.log("2-balance:", balance.toString())

    const amount2 = "9"
    await satori.withdraw(zeroAddress, amount2)
    console.log("withdraw done")

    deposit = await satori.getCommonBalance(zeroAddress, user1)
    console.log("3-deposit:", deposit.toString())

    ethSatoriBalance = await web3.eth.getBalance(satori.address)
    balance = await web3.eth.getBalance(user1)
    console.log("3-satoriBalance:", ethSatoriBalance.toString())
    console.log("3-balance:", balance.toString())
}
module.exports = async (deployer, network, accounts) => {
    // await testTokenDeposit(accounts)
    // await testDeposit(accounts)
    // await testTokenWithdraw(accounts)
    // await testWithdraw(accounts)
}