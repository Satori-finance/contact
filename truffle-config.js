const HDWalletProvider = require('@truffle/hdwallet-provider');
// const infuraKey = "fj4jll3k.....";
//
// const fs = require('fs');
// const mnemonic = fs.readFileSync(".secret").toString().trim();
// const secret = require("./.secret.json")

module.exports = {
  /**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a development blockchain for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   */

  networks: {
    // Useful for testing. The `development` name is special - truffle uses it by default
    // if it's defined here and no other network is specified at the command line.
    // You should run a client (like ganache-cli, geth or parity) in a separate terminal
    // tab if you use this network and you must also set the `host`, `port` and `network_id`
    // options below to some value.
    //
    dev: {      
      host: '127.0.0.1', // Localhost (default: none)
      port: 8545, // Standard Ethereum port (default: none)
      network_id: '*',
      gasPrice: 11000000000,
      gas: 6721975, // Any network (default: none)
    },
    okextest: {      
      provider: function() {
        return new HDWalletProvider(secret.privateKeys, "https://exchaintestrpc.okex.org", 0, 1);
      },
      network_id: 65,
      gasPrice: 1000000000,//(6 Gwei)
      gas: 6721975, // Any network (default: none)
      timeout: 2000000,
    },
    hecotest: {      
      provider: function() {
        return new HDWalletProvider(secret.privateKeys, "https://http-testnet.hecochain.com", 0, 1);
      },
      network_id: 256,
      gasPrice: 6000000000,//(6 Gwei)
      gas: 6721975, // Any network (default: none)
      timeout: 2000000,
    },
    bsctest: {
      provider: function() {
        return new HDWalletProvider(secret.privateKeys, "https://data-seed-prebsc-1-s2.binance.org:8545/", 0, 1);
      },
      network_id: 97,
      gasPrice: 11000000000,//(11 Gwei)
      gas: 6721975, // Any network (default: none)
      timeout: 2000000,
    }
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: '0.6.12+commit.27d51765', // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
       optimizer: {
         enabled: true,
         runs: 200
       },
      }
    },
  },
}
