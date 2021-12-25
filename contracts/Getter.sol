pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./lib/Events.sol";
import "./lib/Transfer.sol";
// import "./lib/Requires.sol";
import "./GlobalStore.sol";

contract Getter is GlobalStore {
    function getAllMarketsCount()
        public
        view
        returns (uint256 count)
    {
        count = state.marketsCount;
    }

    function getCollateralBalance(
        address user
    )
        public
        view
        returns (uint256)
    {
        return state.collateralBalances[user];
    }
}