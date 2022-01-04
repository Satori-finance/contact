pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./Store.sol";
import "./Consts.sol";
// import "./Decimal.sol";
// import "../interfaces/IStandardToken.sol";
// import "../funding/CollateralAccounts.sol";

/**
 * Library to handle restrictions
 */
library Requires {

    //=================== requires ========================

    function requireMarketIdValid(
        Store.State storage state,
        uint256 marketId
    )
        internal
        view
    {
        require(isMarketIdValid(state, marketId), "Requires: Market not exist");
    }

    function requireMarketNotExist(
        Store.State storage state,
        Types.Market memory market
    )
        internal
        view
    {
        require(!isMarketExist(state, market), "Requires: Market already exist");
    }

    function requireMarketAssetsValid(
        Store.State storage state,
        Types.Market memory market
    )
        internal
        view
    {
        require(market.quoteAsset == state.collateralAsset, "Requires: QuoteAsset is invalid");
        require(market.baseAsset != market.quoteAsset, "Requires: BaseAsset and QuoteAsset are duplicated");
    }

    function requireFeeRateValid(
        uint256 feeRate
    )
        internal
        view
    {
        require(feeRate <= Consts.Denominator(), "Requires: invalid fee rate");
    }

    //=================== validates ========================

    function isMarketIdValid(
        Store.State storage state,
        uint256 marketId
    )
        private
        view
        returns(bool)    
    {
        if (state.markets[marketId].valid) {
            return true;
        } else {
            return false;
        }
    }

    function isMarketExist(
        Store.State storage state,
        Types.Market memory market
    )
        private
        view
        returns(bool)
    {
        for(uint16 i = 0; i < state.marketsCount; i++) {
            if (state.markets[i].baseAsset == market.baseAsset && state.markets[i].quoteAsset == market.quoteAsset) {
                return true;
            }
        }

        return false;
    }
}
