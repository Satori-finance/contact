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
    using Position for Types.Position;

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
            if (order.action == Types.OrderAction.Close || order.action == Types.OrderAction.Force) {
                closePosition(order);
            } else if (order.action == Types.OrderAction.Through) {
                throughPosition(order);
            }  else if (order.action == Types.OrderAction.ThroughX) {
                throughXPosition(order);
            } else {
                openOrIncreasePosition(order);
            }
        }
    }

    function openOrIncreasePosition(
        Types.Order memory order
    )
        private
    {
        bytes32 orderHash = order.getHash();
        Types.Position storage position = positions[orderHash];

        require(position.isClosing == false, "Exchange: this position is closing");

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

            Transfer.transferCollateral(state, order.trader, order.collateral);
        }

        position.baseAssetAmount.value = position.baseAssetAmount.value.add(order.baseAssetAmount);
        position.quoteAssetAmount.value = position.quoteAssetAmount.value.add(order.quoteAssetAmount);
    }


    function increaseOrDecreaseCollateral(

    )
        private
    {

    }

    function closePosition(
        Types.Order memory order
    )
        private
    {
        bytes32 orderHash = order.getHash();
        Types.Position storage position = positions[orderHash];
        uint256 baseAssetAmount = order.baseAssetAmount;
        uint256 quoteAssetAmount = order.quoteAssetAmount;

        require(position.baseAssetAmount.value != 0, "Exchange: postion is closed");
        require(baseAssetAmount <= position.baseAssetAmount.value, "Exchange: compensate amount over postion");
        uint256 targetBaseAmount = position.baseAssetAmount.value.sub(baseAssetAmount);

        uint256 targetQuetoAmount = position.quoteAssetAmount.value.
                mul(targetBaseAmount).
                div(position.baseAssetAmount.value);

        uint256 targetCollateral = position.totalCollateral.
                mul(targetBaseAmount).
                div(position.baseAssetAmount.value);  

        require(targetQuetoAmount <= position.quoteAssetAmount.value, "Exchange: invalid target quetoAmount");
        require(targetCollateral <= position.totalCollateral, "Exchange: invalid target collateral");


        uint256 quoteAssetDetal = position.quoteAssetAmount.value.sub(targetQuetoAmount);
        uint256 returnCollateral = position.totalCollateral.sub(targetCollateral);
        uint256 actualReturnCollateral = returnCollateral;

        uint256 x = quoteAssetAmount.add(returnCollateral);
        require(x >= quoteAssetDetal, "Exchange: Collateral not enough");

        if(quoteAssetAmount > quoteAssetDetal) {
            uint256 profit = quoteAssetAmount.sub(quoteAssetDetal);
            Transfer.getProfit(state, position.owner, profit);
        } else {
            uint256 deficit = quoteAssetDetal.sub(quoteAssetAmount);
            actualReturnCollateral = actualReturnCollateral.sub(deficit);
        }

        if (order.action == Types.OrderAction.Close) {
            Transfer.returnCollateral(state, position.owner, returnCollateral, actualReturnCollateral);
        } else {
            Transfer.returnCollateral(state, position.owner, returnCollateral, 0);
            Transfer.addToRiskReserves(state, actualReturnCollateral);
        }

        Types.Wei memory usedCollateral = Types.Wei({
            sign: false,
            value: returnCollateral
        });
        position.returnCollateral(usedCollateral);

        position.baseAssetAmount.value = targetBaseAmount;
        position.quoteAssetAmount.value = targetQuetoAmount;

        position.isClosing = true;
    }

    function throughPosition(
        Types.Order memory order
    )
        private
    {
        bytes32 orderHash = order.getHash();
        Types.Position storage position = positions[orderHash];
        uint256 baseAssetAmount = order.baseAssetAmount;
        uint256 quoteAssetAmount = order.quoteAssetAmount;

        require(position.baseAssetAmount.value != 0, "Exchange: postion is closed");
        require(baseAssetAmount <= position.baseAssetAmount.value, "Exchange: compensate amount over postion");
        uint256 targetBaseAmount = position.baseAssetAmount.value.sub(baseAssetAmount);

        uint256 targetQuetoAmount = position.quoteAssetAmount.value.
                mul(targetBaseAmount).
                div(position.baseAssetAmount.value);

        require(targetQuetoAmount <= position.quoteAssetAmount.value, "Exchange: invalid target quetoAmount");

        uint256 quoteAssetDetal = position.quoteAssetAmount.value.sub(targetQuetoAmount);
        uint256 totalCollateral = position.totalCollateral;
        uint256 avalia = totalCollateral.add(quoteAssetAmount);

        Types.Wei memory usedCollateral = Types.Wei({
            sign: false,
            value: 0
        });

        if (avalia >= quoteAssetDetal) {
            if (quoteAssetDetal > quoteAssetAmount) {
                usedCollateral.value = quoteAssetDetal.sub(quoteAssetAmount);
            }
        } else {
            usedCollateral.value = position.totalCollateral;

            Transfer.useRiskReserves(state, quoteAssetDetal.sub(avalia));  
        }

        position.returnCollateral(usedCollateral);
        Transfer.returnCollateral(state, position.owner, usedCollateral.value, 0);

        position.baseAssetAmount.value = targetBaseAmount;
        position.quoteAssetAmount.value = targetQuetoAmount;
        position.isClosing = true;
    }

    function throughXPosition(
        Types.Order memory order
    ) private {

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
        order.collateral = orderParam.collateral;
        order.action = orderParam.action;
        order.data = orderParam.data;

        uint256 marketId = order.getMarkId();
        Types.Market memory market = getMarket(marketId);
        order.baseAsset = market.baseAsset;
        order.quoteAsset = market.quoteAsset;
    }
}