pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./lib/Store.sol";

contract GlobalStore {
    Store.State state;

    function getMarket(
        uint256 marketId
    )
        internal
        view
        returns (Types.Market memory market)
    {
        require(marketId < state.marketsCount, "Store: Market not exist");
        require(state.markets[marketId].valid, "Store: Invalid market");
        market = state.markets[marketId];
    }
}