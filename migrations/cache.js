var contracts = {}

function saveContract(key, instant) {
    contracts[key] = instant
}

function getContract(key) {
    return contracts[key]
}

module.exports = {
    contracts,
    saveContract,
    getContract
}