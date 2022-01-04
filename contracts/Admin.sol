pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/access/Ownable.sol';

import "./lib/Types.sol";
import "./lib/Requires.sol";
import "./lib/Transfer.sol";
import "./lib/Events.sol";
import "./GlobalStore.sol";

import '@nomiclabs/buidler/console.sol';

contract Admin is Ownable, GlobalStore {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    function createMarket(
        Types.Market memory market
    )
        public
        onlyOwner
    {
        Requires.requireMarketNotExist(state, market);
        Requires.requireMarketAssetsValid(state, market);

        market.valid = true;

        state.markets[state.marketsCount++] = market;
        Events.logCreateMarket(market);
    }

    function updateMarket(
        uint16 marketId,
        uint256 asMakerFeeRate,
        uint256 asTakerFeeRate
    )
        public
        onlyOwner
    {
        Requires.requireMarketIdValid(state, marketId);

        Requires.requireFeeRateValid(asMakerFeeRate);
        Requires.requireFeeRateValid(asTakerFeeRate);

        state.markets[marketId].asMakerFeeRate = asMakerFeeRate;
        state.markets[marketId].asTakerFeeRate = asTakerFeeRate;

        Events.logUpdateMarket(state.markets[marketId]);
    }    

    function depositForRisk(
        uint256 amount
    )
        public
    {
        address from = msg.sender;
        address asset = state.collateralAsset;

        state.riskReserves = state.riskReserves.add(amount);

        Transfer.transferIn(asset, from, amount);

        Events.depositForRisk(from, amount);
    }

    function withdrawFromRisk(
        uint256 amount
    )
        public
        onlyOwner
    {
        address to = msg.sender;
        address asset = state.collateralAsset;

        require(state.riskReserves >= amount, "Admin: risk reserves not enough");

        state.riskReserves = state.riskReserves.sub(amount);

        Transfer.transferOut(asset, to, amount);

        Events.withdrawFromRisk(amount);
    }
}