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

        bool valid;
    }

    struct Position {
        uint256 marketId;
        address owner;           //position owner
        uint256 baseCollateral;  //base collateral(usdc)
        uint256 totalCollateral; //total collateral(usdc)
        address baseAsset;       //token
        address quoteAsset;      //usdc
        Wei baseAssetAmount;     //token amount
        Wei quoteAssetAmount;    //usdc amount
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
        bool    close;
        bytes32 data;
        // Signature signature;
    }

    struct MatchParams {
        OrderParam       takerOrderParam;
        OrderParam[]     makerOrderParams;
    }

    struct Order {
        address trader;
        address baseAsset;        //other token
        address quoteAsset;       //usdc
        uint256 baseAssetAmount;  //token amount
        uint256 quoteAssetAmount; //usdc amount
        uint256 collateral;
        bool    close;
        /**
         * Data contains the following values packed into 32 bytes
         * ╔════════════════════╤═══════════════════════════════════════════════════════════╗
         * ║                    │ length(bytes)   desc                                      ║
         * ╟────────────────────┼───────────────────────────────────────────────────────────╢
         * ║ version            │ 1               order version                             ║
         * ║ side               │ 1               0: buy, 1: sell                           ║
         * ║ isMarketOrder      │ 1               0: limitOrder, 1: marketOrder             ║
         * ║ isMakerOnly        │ 1               is maker only                             ║
         * ║ marketID           │ 2               marketID                                  ║
         * ║ salt               │ 8               salt                                      ║
         * ║                    │ 18              reserved                                  ║
         * ╚════════════════════╧═══════════════════════════════════════════════════════════╝
         */
        bytes32 data;
    }
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
        return uint8(order.data[3]) == 1;
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

    function getMarkId(
        Types.Order memory order
    )
        internal
        pure
        returns (uint256)
    {
        return uint256(uint16(bytes2(order.data << (8*4))));
    }
}

library Position {

}
