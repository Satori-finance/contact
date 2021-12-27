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

    function transferCollateral(
        Store.State storage state,
        address account,
        Types.Wei memory collateral
    )
        internal
    {
        if (collateral.sign) {
            state.collateralBalances[account] = state.collateralBalances[account].add(collateral.value);
            state.collateralTotal = state.collateralTotal.sub(collateral.value);
        } else {
            state.collateralBalances[account] = state.collateralBalances[account].sub(collateral.value);
            state.collateralTotal = state.collateralTotal.add(collateral.value);
        }
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