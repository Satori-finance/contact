pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "./lib/Types.sol";
import "./lib/Transfer.sol";
import "./GlobalStore.sol";

import '@nomiclabs/buidler/console.sol';

contract Exchange is
    Ownable,
    GlobalStore,
    ReentrancyGuard
{
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Order for Types.Order;
    using OrderParam for Types.OrderParam;

    struct OrderInfo {
        bytes32 orderHash;
        uint256 filledAmount;
    }

    mapping (bytes32 => Types.Position) public positions;

    // only permission
    function matchOrders(
        Types.MatchParams memory params
    )
        public
        nonReentrant
    {
        //validate
        console.log("start match");

        Types.Order memory takerOrder = getOrderFromOrderParam(params.takerOrderParam, params.orderAddressSet);
        bytes32 takerHash = takerOrder.getHash();
        Types.Position storage takerPosition = positions[takerHash];
        
        console.log("takerHash: %s", uint256(takerHash));


        if (takerPosition.baseCollateral == 0) {
            takerPosition.baseCollateral  = takerOrder.collateral;
            takerPosition.totalCollateral = takerOrder.collateral;
            //TODO more


            Types.Wei memory takerCollateral = Types.Wei({
                sign: false,
                value: takerOrder.collateral
            });

            console.log("00 takerOrder.collateral: %s", takerOrder.collateral);

            Transfer.transferCollateral(state, takerOrder.trader, takerCollateral);
        }


        uint256 takerAmount = takerOrder.baseAssetAmount;


        for (uint256 i = 0; i < params.makerOrderParams.length; i++) {
            Types.Order memory makerOrder = getOrderFromOrderParam(params.makerOrderParams[i], params.orderAddressSet);
            require(!makerOrder.isMarketOrder(), "Exchange: maker order can not be market order");
            require(takerOrder.isSell() != makerOrder.isSell(), "Exchange: invalid side");
            validatePrice(takerOrder, makerOrder);

            bytes32 makerHash = makerOrder.getHash();
            Types.Position storage makerPosition = positions[makerHash];

            console.log("takerOrder.collateral: %s", takerOrder.collateral);
            console.log("makerOrder.collateral: %s", makerOrder.collateral);


            if (makerPosition.baseCollateral == 0) {
                makerPosition.baseCollateral  = makerOrder.collateral;
                makerPosition.totalCollateral = makerOrder.collateral;

                //TODO more


                Types.Wei memory makerCollateral = Types.Wei({
                    sign: false,
                    value: makerOrder.collateral
                });
                Transfer.transferCollateral(state, makerOrder.trader, makerCollateral);
            }

            uint256 price = makerOrder.quoteAssetAmount; //价格
            if (!takerOrder.isMarketOrder() && !takerOrder.isSell()) {
                price = takerOrder.quoteAssetAmount;
            }

            uint256 makerAmount = makerOrder.baseAssetAmount;
            if (takerAmount < makerAmount) {
                makerAmount = takerAmount;
            }

            if (params.takerOrderParam.isSell()) {
                console.log("params.takerOrderParam.isSell=true");

                price = makerOrder.quoteAssetAmount;

                //sell base asset


                takerPosition.baseAssetAmount.sign = false;
                takerPosition.quoteAssetAmount.sign = true;

                makerPosition.baseAssetAmount.sign = true;
                makerPosition.quoteAssetAmount.sign = false;
            } else {
                console.log("params.takerOrderParam.isSell=false");
                //buy base asset


                makerPosition.baseAssetAmount.sign = true;
                makerPosition.quoteAssetAmount.sign = false;


                makerPosition.baseAssetAmount.sign = false;
                makerPosition.quoteAssetAmount.sign = true;
            }


            takerPosition.baseAssetAmount.value = takerPosition.baseAssetAmount.value.
                add(makerAmount);
            takerPosition.quoteAssetAmount.value = takerPosition.quoteAssetAmount.value.
                add(price.mul(makerAmount));


            makerPosition.baseAssetAmount.value = makerPosition.baseAssetAmount.value.
                add(makerAmount);

            makerPosition.quoteAssetAmount.value = makerPosition.quoteAssetAmount.value.
                add(price.mul(makerAmount));     

            takerAmount = takerAmount.sub(makerAmount);
        }
    }

    function getOrderFromOrderParam(
        Types.OrderParam memory orderParam,
        Types.OrderAddressSet memory orderAddressSet
    )
        private
        pure
        returns (Types.Order memory order)
    {
        order.trader = orderParam.trader;                   //
        order.baseAssetAmount = orderParam.baseAssetAmount; //usdc amount  1000
        order.quoteAssetAmount = orderParam.quoteAssetAmount; //eth amount 100
        order.collateral = orderParam.collateral;            //
        // order.gasTokenAmount = orderParam.gasTokenAmount;
        order.data = orderParam.data;
        order.baseAsset = orderAddressSet.baseAsset;
        order.quoteAsset = orderAddressSet.quoteAsset;
        // order.relayer = orderAddressSet.relayer;
    }

    function validatePrice(
        Types.Order memory takerOrder,
        Types.Order memory makerOrder
    )
        private
        pure
    {
        if (!takerOrder.isMarketOrder()) {
            if (takerOrder.isSell()) {
                require(takerOrder.quoteAssetAmount <= makerOrder.quoteAssetAmount, "Exchange: sell queto amount not match");
            } else {
                require(takerOrder.quoteAssetAmount >= makerOrder.quoteAssetAmount, "Exchange: buy queto amount not match");
            }
        }
    }
}