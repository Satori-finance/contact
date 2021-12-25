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

contract Exchangeold is
    Ownable,
    GlobalStore,
    ReentrancyGuard
{
    // using SafeERC20 for IERC20;
    // using SafeMath for uint256;
    // using Order for Types.Order;
    // using OrderParam for Types.OrderParam;

    // mapping (bytes32 => Types.Position) public positions;
    // bytes32[] public allPositions;

    // address public matchOperator;

    // //======== modifer =======
    // modifier onlyMatchOperator() {
    //     // require(msg.sender == matchOperator, "Exchange: Only match operator");

    //     _;
    // }

    // //onwer
    // function setMatchOperator(address _matchOperator) public onlyOwner {
    //     require(_matchOperator != address(0), "Oracle: invalid new match operator");

    //     _;
    // }

    // //view
    // function positionNumber() public view returns(uint256) {
    //     return allPositions.length;
    // }

    // // only operator
    // function matchOrders(
    //     Types.MatchParams memory params
    // )
    //     public
    //     onlyMatchOperator
    //     nonReentrant
    // {
    //     console.log("start match");

    //     //validate

    //     Types.Order memory takerOrder = getOrderFromOrderParam(params.takerOrderParam);
    //     bytes32 takerHash = takerOrder.getHash();
    //     Types.Position storage takerPosition = positions[takerHash];

    //     //Opening margin
    //     if (takerPosition.baseCollateral == 0) {
    //         allPositions.push(takerHash);

    //         takerPosition.marketId = takerOrder.getMarkId();
    //         takerPosition.owner = takerOrder.trader;
    //         takerPosition.baseAsset = takerOrder.baseAsset;
    //         takerPosition.quoteAsset = takerOrder.quoteAsset;
    //         takerPosition.baseCollateral = takerOrder.collateral;
    //         takerPosition.totalCollateral = takerOrder.collateral;

    //         //Draw down margin
    //         Types.Wei memory takerCollateral = Types.Wei({
    //             sign: false,
    //             value: takerOrder.collateral
    //         });

    //         Transfer.transferCollateral(state, takerOrder.trader, takerCollateral);
    //     }

    //     //Taker needs to eat the number of orders
    //     uint256 takerAmount = takerOrder.baseAssetAmount;

    //     //Eat a single process
    //     for (uint256 i = 0; i < params.makerOrderParams.length; i++) {
    //         Types.Order memory makerOrder = getOrderFromOrderParam(params.makerOrderParams[i]);
    //         require(!makerOrder.isMarketOrder(), "Exchange: maker order can not be market order");
    //         require(takerOrder.isSell() != makerOrder.isSell(), "Exchange: invalid side");
    //         require(takerOrder.getMarkId() == makerOrder.getMarkId(), "Exchange: marketId not match");

    //         validatePrice(takerOrder, makerOrder);

    //         bytes32 makerHash = makerOrder.getHash();

    //         Types.Position storage makerPosition = positions[makerHash];

    //         //Opening margin
    //         if (makerPosition.baseCollateral == 0) {
    //             allPositions.push(makerHash);
 
    //             makerPosition.marketId = makerOrder.getMarkId();
    //             makerPosition.owner = makerOrder.trader;
    //             makerPosition.baseAsset = makerOrder.baseAsset;
    //             makerPosition.quoteAsset = makerOrder.quoteAsset;
    //             makerPosition.baseCollateral = makerOrder.collateral;
    //             makerPosition.totalCollateral = makerOrder.collateral;

    //             //Draw down margin
    //             Types.Wei memory makerCollateral = Types.Wei({
    //                 sign: false,
    //                 value: makerOrder.collateral
    //             });
    //             Transfer.transferCollateral(state, makerOrder.trader, makerCollateral);
    //         }

    //         uint256 price = makerOrder.quoteAssetAmount; //price
    //         if (!takerOrder.isMarketOrder() && !takerOrder.isSell()) {
    //             price = takerOrder.quoteAssetAmount;
    //         }

    //         uint256 makerAmount = makerOrder.baseAssetAmount;
    //         if (takerAmount < makerAmount) {
    //             makerAmount = takerAmount;
    //         }

    //         if (params.takerOrderParam.isSell()) {
    //             //If Taker is a sell order, use a Maker price
    //             price = makerOrder.quoteAssetAmount;

    //             //sell base asset

    //             //Taker positions
    //             takerPosition.baseAssetAmount.sign = false;
    //             takerPosition.quoteAssetAmount.sign = true;
                
    //             //Maker positions
    //             makerPosition.baseAssetAmount.sign = true;
    //             makerPosition.quoteAssetAmount.sign = false;
    //         } else {
    //             //buy base asset

    //             //Taker positions
    //             makerPosition.baseAssetAmount.sign = true;
    //             makerPosition.quoteAssetAmount.sign = false;

    //             //Maker positions
    //             makerPosition.baseAssetAmount.sign = false;
    //             makerPosition.quoteAssetAmount.sign = true;
    //         }

    //         //Taker positions
    //         takerPosition.baseAssetAmount.value = takerPosition.baseAssetAmount.value.
    //             add(makerAmount);
    //         takerPosition.quoteAssetAmount.value = takerPosition.quoteAssetAmount.value.
    //             add(price.mul(makerAmount));

    //         //Maker positions
    //         makerPosition.baseAssetAmount.value = makerPosition.baseAssetAmount.value.
    //             add(makerAmount);

    //         makerPosition.quoteAssetAmount.value = makerPosition.quoteAssetAmount.value.
    //             add(price.mul(makerAmount));     

    //         takerAmount = takerAmount.sub(makerAmount);
    //     }
    // }

    // function getOrderFromOrderParam(
    //     Types.OrderParam memory orderParam
    // )
    //     private
    //     view
    //     returns (Types.Order memory order)
    // {
    //     order.trader = orderParam.trader;
    //     order.baseAssetAmount = orderParam.baseAssetAmount;
    //     order.quoteAssetAmount = orderParam.quoteAssetAmount;
    //     order.collateral = orderParam.collateral; //Margin
    //     order.data = orderParam.data;
        
    //     uint256 marketId = order.getMarkId();
    //     Types.Market memory market = getMarket(marketId);
    //     order.baseAsset = market.baseAsset;
    //     order.quoteAsset = market.quoteAsset;
    // }

    // function validatePrice(
    //     Types.Order memory takerOrder,
    //     Types.Order memory makerOrder
    // )
    //     private
    //     pure
    // {
    //     if (!takerOrder.isMarketOrder()) {
    //         if (takerOrder.isSell()) {
    //             require(takerOrder.quoteAssetAmount <= makerOrder.quoteAssetAmount, "Exchange: Sell queto amount not match");
    //         } else {
    //             require(takerOrder.quoteAssetAmount >= makerOrder.quoteAssetAmount, "Exchange: Buy queto amount not match");
    //         }
    //     }
    // }

    // function validateOrder(
    //     Types.Order memory takerOrder
    // )
    //     private
    //     pure
    // {
        
    // }
}