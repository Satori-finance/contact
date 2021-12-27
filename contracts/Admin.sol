pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/access/Ownable.sol';

import "./lib/Types.sol";
import "./lib/Requires.sol";
import "./lib/Events.sol";
import "./GlobalStore.sol";

contract Admin is Ownable, GlobalStore {
    function createMarket(
        Types.Market memory market
    )
        public
        onlyOwner
    {
        Requires.requireMarketAssetsValid(state, market);
        Requires.requireMarketNotExist(state, market);
        // Requires.requireDecimalLessOrEquanThanOne(market.auctionRatioStart);
        // Requires.requireDecimalLessOrEquanThanOne(market.auctionRatioPerBlock);
        // Requires.requireDecimalGreaterThanOne(market.liquidateRate);
        // Requires.requireDecimalGreaterThanOne(market.withdrawRate);
        // require(market.withdrawRate > market.liquidateRate, "WITHDARW_RATE_LESS_OR_EQUAL_THAN_LIQUIDATE_RATE");

        state.markets[state.marketsCount++] = market;
        Events.logCreateMarket(market);
    }
}