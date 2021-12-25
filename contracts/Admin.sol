pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/access/Ownable.sol';

import "./lib/Types.sol";
import "./lib/Requires.sol";
import "./lib/Events.sol";
import "./GlobalStore.sol";

import '@nomiclabs/buidler/console.sol';

contract Admin is Ownable, GlobalStore {
    function createMarket(
        Types.Market memory market
    )
        public
        onlyOwner
    {
        Requires.requireMarketAssetsValid(state, market);
        Requires.requireMarketNotExist(state, market);

        market.valid = true;

        state.markets[state.marketsCount++] = market;
        Events.logCreateMarket(market);
    }
}