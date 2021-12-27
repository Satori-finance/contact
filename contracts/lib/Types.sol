pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./Store.sol";

library Types {
    struct Wei {
        bool    sign; // true if positive
        uint256 value;
    }

    struct Market {
        address baseAsset;  //token
        address quoteAsset; //usdc
    }

    struct Position {
        uint256 marketId;
        uint256 baseCollateral; //base collateral(usdc)
        uint256 totalCollateral; //total collateral(usdc)

        Wei baseAssetAmount;  //token amount
        Wei quoteAssetAmount; //usdc amount
    }

    struct Signature {
        /**
         * Config contains the following values packed into 32 bytes
         * ╔════════════════════╤═══════════════════════════════════════════════════════════╗
         * ║                    │ length(bytes)   desc                                      ║
         * ╟────────────────────┼───────────────────────────────────────────────────────────╢
         * ║ v                  │ 1               the v parameter of a signature            ║
         * ║ signatureMethod    │ 1               SignatureMethod enum value                ║
         * ╚════════════════════╧═══════════════════════════════════════════════════════════╝
         */
        bytes32 config;
        bytes32 r;
        bytes32 s;
    }

    struct OrderParam {
        address trader;
        uint256 baseAssetAmount;  //other token amount
        uint256 quoteAssetAmount; //usdc amount
        uint256 collateral;
        bytes32 data;
        // Signature signature;
    }

    struct OrderAddressSet {
        address baseAsset;
        address quoteAsset;
        // address relayer;
    }

    struct MatchParams {
        OrderParam       takerOrderParam;
        OrderParam[]     makerOrderParams;
        // uint256[]        baseAssetFilledAmounts;
        OrderAddressSet  orderAddressSet;
    }

    struct Order {
        address trader;
        address baseAsset;        //other token
        address quoteAsset;       //usdc
        uint256 baseAssetAmount;  //token amount
        uint256 quoteAssetAmount; //usdc amount
        // uint256 gasTokenAmount;   //use usdc for gas???
        uint256 collateral;
        /**
         * Data contains the following values packed into 32 bytes
         * ╔════════════════════╤═══════════════════════════════════════════════════════════╗
         * ║                    │ length(bytes)   desc                                      ║
         * ╟────────────────────┼───────────────────────────────────────────────────────────╢
         * ║ version            │ 1               order version                             ║
         * ║ side               │ 1               0: buy, 1: sell                           ║
         * ║ isMarketOrder      │ 1               0: limitOrder, 1: marketOrder             ║
         * ║ expiredAt          │ 5               order expiration time in seconds          ║
         * ║ asMakerFeeRate     │ 2               maker fee rate (base 100,000)             ║
         * ║ asTakerFeeRate     │ 2               taker fee rate (base 100,000)             ║
         * ║ makerRebateRate    │ 2               rebate rate for maker (base 100)          ║
         * ║ salt               │ 8               salt                                      ║
         * ║ isMakerOnly        │ 1               is maker only                             ║
         * ║ balancesType       │ 1               0: common, 1: collateralAccount           ║
         * ║ marketID           │ 2               marketID                                  ║
         * ║                    │ 6               reserved                                  ║
         * ╚════════════════════╧═══════════════════════════════════════════════════════════╝
         */
        bytes32 data;
    }

    // struct MatchResult {
    //     address maker;
    //     address taker;
    //     address buyer;
    //     uint256 makerFee;
    //     uint256 makerRebate;
    //     uint256 takerFee;
    //     uint256 makerGasFee;
    //     uint256 takerGasFee;
    //     uint256 baseAssetFilledAmount;
    //     uint256 quoteAssetFilledAmount;
    //     BalancePath makerBalancePath;
    //     BalancePath takerBalancePath;
    // }
}

library OrderParam {
    /* Functions to extract info from data bytes in Order struct */

    function getOrderVersion(
        Types.OrderParam memory order
    )
        internal
        pure
        returns (uint256)
    {
        return uint256(uint8(byte(order.data)));
    }

    function getExpiredAtFromOrderData(
        Types.OrderParam memory order
    )
        internal
        pure
        returns (uint256)
    {
        return uint256(uint40(bytes5(order.data << (8*3))));
    }

    function isSell(
        Types.OrderParam memory order
    )
        internal
        pure
        returns (bool)
    {
        return uint8(order.data[1]) == 1;
    }

    function isMarketOrder(
        Types.OrderParam memory order
    )
        internal
        pure
        returns (bool)
    {
        return uint8(order.data[2]) == 1;
    }

    function isMakerOnly(
        Types.OrderParam memory order
    )
        internal
        pure
        returns (bool)
    {
        return uint8(order.data[22]) == 1;
    }

    function isMarketBuy(
        Types.OrderParam memory order
    )
        internal
        pure
        returns (bool)
    {
        return !isSell(order) && isMarketOrder(order);
    }

    function getAsMakerFeeRateFromOrderData(
        Types.OrderParam memory order
    )
        internal
        pure
        returns (uint256)
    {
        return uint256(uint16(bytes2(order.data << (8*8))));
    }

    function getAsTakerFeeRateFromOrderData(
        Types.OrderParam memory order
    )
        internal
        pure
        returns (uint256)
    {
        return uint256(uint16(bytes2(order.data << (8*10))));
    }

    // function getMakerRebateRateFromOrderData(
    //     Types.OrderParam memory order
    // )
    //     internal
    //     pure
    //     returns (uint256)
    // {
    //     uint256 makerRebate = uint256(uint16(bytes2(order.data << (8*12))));

    //     // make sure makerRebate will never be larger than REBATE_RATE_BASE, which is 100
    //     return SafeMath.min(makerRebate, Consts.REBATE_RATE_BASE());
    // }

    // function getBalancePathFromOrderData(
    //     Types.OrderParam memory order
    // )
    //     internal
    //     pure
    //     returns (Types.BalancePath memory)
    // {
    //     Types.BalanceCategory category;
    //     uint16 marketID;

    //     if (byte(order.data << (8*23)) == "\x01") {
    //         category = Types.BalanceCategory.CollateralAccount;
    //         marketID = uint16(bytes2(order.data << (8*24)));
    //     } else {
    //         category = Types.BalanceCategory.Common;
    //         marketID = 0;
    //     }

    //     return Types.BalancePath({
    //         user: order.trader,
    //         category: category,
    //         marketID: marketID
    //     });
    // }
}

library Order {
    function getHash(
        Types.Order memory order
    )
        internal
        pure
        returns (bytes32)
    {
        bytes32 orderHash = keccak256(
            abi.encodePacked(
                order.trader,
                order.baseAsset,
                order.quoteAsset,
                order.data
            )
        );
        return orderHash;
    }

    function getOrderVersion(
        Types.Order memory order
    )
        internal
        pure
        returns (uint256)
    {
        return uint256(uint8(byte(order.data)));
    }

    function getExpiredAtFromOrderData(
        Types.Order memory order
    )
        internal
        pure
        returns (uint256)
    {
        return uint256(uint40(bytes5(order.data << (8*3))));
    }

    function isSell(
        Types.Order memory order
    )
        internal
        pure
        returns (bool)
    {
        return uint8(order.data[1]) == 1;
    }

    function isMarketOrder(
        Types.Order memory order
    )
        internal
        pure
        returns (bool)
    {
        return uint8(order.data[2]) == 1;
    }

    function isMakerOnly(
        Types.Order memory order
    )
        internal
        pure
        returns (bool)
    {
        return uint8(order.data[22]) == 1;
    }

    function isMarketBuy(
        Types.Order memory order
    )
        internal
        pure
        returns (bool)
    {
        return !isSell(order) && isMarketOrder(order);
    }

    function getAsMakerFeeRateFromOrderData(
        Types.Order memory order
    )
        internal
        pure
        returns (uint256)
    {
        return uint256(uint16(bytes2(order.data << (8*8))));
    }

    function getAsTakerFeeRateFromOrderData(
        Types.Order memory order
    )
        internal
        pure
        returns (uint256)
    {
        return uint256(uint16(bytes2(order.data << (8*10))));
    }
}

library Position {

}
