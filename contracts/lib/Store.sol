pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./Types.sol";

library Store {
    struct State {
        uint256 marketsCount;

        address collateralAsset; //usdc

        uint256 collateralTotal; //
        
        uint256 riskReserves; //

        // all markets
        mapping(uint256 => Types.Market) markets;

        //user => balance
        mapping(address => uint256) collateralBalances; //usdc

        // order hash => position info
        mapping(bytes32 => Types.Position) positions;
    }
}