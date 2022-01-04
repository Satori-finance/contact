const BigNumber = require('bignumber.js');

const addLeadingZero = (str, length) => {
    let len = str.length;
    return '0'.repeat(length - len) + str;
};

const addTailingZero = (str, length) => {
    let len = str.length;
    return str + '0'.repeat(length - len);
};

const generateOrderData = (param) => {
    const version  = param.version
    const isSell   = param.isSell
    const isMarket = param.isMarket
    const isMakerOnly = param.isMakerOnly
    const marketId = param.marketId
    const salt = param.salt

    let res = '0x';
    res += addLeadingZero(new BigNumber(version).toString(16), 2);
    res += isSell ? '01' : '00';
    res += isMarket ? '01' : '00';
    res += isMakerOnly ? '01' : '00';

    res += addLeadingZero(new BigNumber(marketId).toString(16), 2 * 2);
    res += addLeadingZero(new BigNumber(salt).toString(16), 8 * 2);

    return addTailingZero(res, 66);
};


//@time: "2021-06-30 14:58:20"
function parseTime(t) {
    return parseInt(Date.parse(t) / 1000);
}

function appendZero(t) {
    if (t < 10) {
        return `0${t}`
    } else {
        return `${t}`
    }
}

function formatDate(t) {
    let years   = appendZero(t.getFullYear())
    let months  = appendZero(t.getMonth() + 1)
    let days    = appendZero(t.getDate())
    let hours   = appendZero(t.getHours())
    let minutes = appendZero(t.getMinutes())
    let seconds = appendZero(t.getSeconds())

    return `${years}-${months}-${days} ${hours}:${minutes}:${seconds}`
}

function formatDateWithoutSeparator(t) {
    let years   = appendZero(t.getFullYear())
    let months  = appendZero(t.getMonth() + 1)
    let days    = appendZero(t.getDate())
    let hours   = appendZero(t.getHours())
    let minutes = appendZero(t.getMinutes())
    let seconds = appendZero(t.getSeconds())

    return `${years}${months}${days}${hours}${minutes}${seconds}`
}

module.exports = {
    parseTime,
    formatDate,
    formatDateWithoutSeparator,

    generateOrderData
}