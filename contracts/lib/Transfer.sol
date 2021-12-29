pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

import "./Types.sol";
import "./Store.sol";

import '@nomiclabs/buidler/console.sol';

library Transfer {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    function getProfit(
        Store.State storage state,
        address account,
        uint256 amount
    )
        internal
    {
        state.collateralBalances[account] = state.collateralBalances[account].add(amount);
    }

    function addToRiskReserves(
        Store.State storage state,
        uint256 amount
    )
        internal
    {
        state.riskReserves = state.riskReserves.add(amount);
    }

    function useRiskReserves(
        Store.State storage state,
        uint256 amount
    )
        internal
    {
        require(state.riskReserves > amount, "Transfer: risk reserves not enough");
        state.riskReserves = state.riskReserves.sub(amount);
    }

    function transferCollateral(
        Store.State storage state,
        address account,
        uint256 amount
    )
        internal
    {
        require(state.collateralBalances[account] >= amount, "Transfer: collateral balance not enough");
        state.collateralBalances[account] = state.collateralBalances[account].sub(amount);
        state.collateralTotal = state.collateralTotal.add(amount);
    }

    function returnCollateral(
        Store.State storage state,
        address account,
        uint256 amount,
        uint256 actual
    )
        internal
    {
        require(amount >= actual, "Transfer: invalid amount");
        state.collateralBalances[account] = state.collateralBalances[account].add(actual);
        state.collateralTotal = state.collateralTotal.sub(amount);
    }

    function transferIn (
        address token,
        address from,
        uint256 amount
    ) 
        internal
    {
        if (address(token) != address(0)) {
            IERC20(token).safeTransferFrom(from, address(this), amount);
        }
    }

    function transferOut (
        address token,
        address to,
        uint256 amount
    ) 
        internal
    {
        if (address(token) == address(0)) {
            safeTransferETH(to, amount);
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'ETH_TRANSFER_FAILED');
    }
}