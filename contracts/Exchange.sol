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
    // using OrderParam for Types.OrderParam;

    mapping (bytes32 => Types.Position) public positions;
    bytes32[] public allPositions;

    address public matchOperator;

    //======== modifer =======
    modifier onlyMatchOperator() {
        // require(msg.sender == matchOperator, "Exchange: Only match operator");

        _;
    }

    //======== onwer =======
    function setMatchOperator(address _matchOperator) public onlyOwner {
        require(_matchOperator != address(0), "Exchange: invalid new match operator");

        matchOperator = _matchOperator;
    }

    //======== view =======
    function positionNumber() public view returns(uint256) {
        return allPositions.length;
    }

    //======== only operator =======
    function matchOrders(
        Types.OrderParam[] memory params
    )
        public
        onlyMatchOperator
        nonReentrant
    {
        for (uint256 i = 0; i < params.length; i++) {
            Types.Order memory order = getOrderFromOrderParam(params[i]);
            if (order.close) {
                closePosition(order);
            } else {
                openOrIncreasePosition(order);
            }
        }
    }

    function closePosition(
        Types.Order memory order
    )
        private
    {
        bytes32 orderHash = order.getHash();
        Types.Position storage position = positions[orderHash];
        uint256 baseAssetAmount = order.baseAssetAmount;

        require(baseAssetAmount <= position.baseAssetAmount.value, "Exchange: compensate amount over postion");
        require(quoteAssetAmount <= position.baseAssetAmount.value, "Exchange: compensate amount over postion");

        // compensate
        position.baseAssetAmount.value = position.baseAssetAmount.value.sub(baseAssetAmount);
        position.quoteAssetAmount.value = position.baseAssetAmount.value.sub(quoteAssetAmount);

        //TODO: How to deal with margin when partial cover position
    }

    function openOrIncreasePosition(
        Types.Order memory order
    )
        private
    {
        bytes32 orderHash = order.getHash();
        Types.Position storage position = positions[orderHash];

        //开仓保证金
        if (position.baseCollateral == 0) {
            allPositions.push(orderHash);

            position.marketId = order.getMarkId();
            position.owner = order.trader;
            position.baseAsset = order.baseAsset;
            position.quoteAsset = order.quoteAsset;
            position.baseCollateral = order.collateral;
            position.totalCollateral = order.collateral;

            if (order.isSell()) {
                // position.baseAssetAmount.sign = false;
                position.quoteAssetAmount.sign = true;
            } else {
                position.baseAssetAmount.sign = true;
                // position.quoteAssetAmount.sign = false;
            }

            //划走保证金
            Types.Wei memory orderCollateral = Types.Wei({
                sign: false,
                value: order.collateral
            });

            Transfer.transferCollateral(state, order.trader, orderCollateral);
        }

        position.baseAssetAmount.value = position.baseAssetAmount.value.add(order.baseAssetAmount);
        position.quoteAssetAmount.value = position.quoteAssetAmount.value.add(order.quoteAssetAmount);
    }

    function getOrderFromOrderParam(
        Types.OrderParam memory orderParam
    )
        private
        view
        returns (Types.Order memory order)
    {
        order.trader = orderParam.trader;
        order.baseAssetAmount = orderParam.baseAssetAmount;
        order.quoteAssetAmount = orderParam.quoteAssetAmount;
        order.collateral = orderParam.collateral; //Margin
        order.close = orderParam.close;
        order.data = orderParam.data;

        uint256 marketId = order.getMarkId();
        Types.Market memory market = getMarket(marketId);
        order.baseAsset = market.baseAsset;
        order.quoteAsset = market.quoteAsset;
    }
}