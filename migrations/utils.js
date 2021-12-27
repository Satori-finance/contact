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
}