const fs = require('fs');
const path = require('path');
const util = require('util');

const writeFile = util.promisify(fs.writeFile);

const { contracts, poolConfig } = require('./cache');
const { chains, tokenKeys, otherKeys, NFTs, ckeys, serverUrl, Platform_Admin, pools } = require('./config');
const { formatDate, formatDateWithoutSeparator } = require('./utils');

module.exports = async (deployer, network, accounts) => {
    const chainid = await web3.eth.net.getId()
    console.log(`chain id:${chainid}`)

    const now = new Date()

    const deployments = {
      "timestamp": formatDate(now),
      "node": chains[network] ? chains[network].node : "",
      "browser": chains[network] ? chains[network].browser : "",
      "swapURL": chains[network] ? chains[network].swapURL : "",
      "chainid": chainid,
      "chainName": chains[network] ? chains[network].chainName : "dev",
      "chainSymbol": chains[network] ? chains[network].symbol : "",
      "chainSymbolDecimals": chains[network].symbolDecimals,
      "server": serverUrl,
    };

    let allContract = {}
    
    for (var i = 0; i < tokenKeys.length; i++) {
      let key = tokenKeys[i]
      if (!contracts[key]) {
        continue
      }
      console.log(`${key}:${contracts[key].address}`);
      let decimals = await contracts[key].decimals()      
      allContract[key] = {
        address:  contracts[key].address,
        abi:      contracts[key].abi,
        decimals: decimals.toNumber(),
      }
    }

    for (var i = 0; i < otherKeys.length; i++) {
      let key = otherKeys[i]
      if (!contracts[key]) {
        continue
      }
      console.log(`${key}:${contracts[key].address}`);
      allContract[key] = {
        address:  contracts[key].address,
        abi:      contracts[key].abi,
      }
    }
    deployments["contracts"] = allContract

    const deploymentPath = path.resolve(__dirname, `../build/deployments.${network}.${formatDateWithoutSeparator(now)}.json`)
    await writeFile(deploymentPath, JSON.stringify(deployments, null, 2))
};
