pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';


import "./lib/Events.sol";
import "./lib/Types.sol";
import "./lib/Transfer.sol";
import "./GlobalStore.sol";
import "./lib/Requires.sol";

contract Operations is GlobalStore, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    function deposit(
        uint256 amount
    )
        public
        payable
        nonReentrant
    {
        address from = msg.sender;
        address asset = state.collateralAsset;

        if (address(asset) == address(0)) {
            amount = msg.value;
        }

        require(amount > 0, "Operations: deposit amount must greater than zero");

        state.collateralBalances[from] = state.collateralBalances[from].add(amount);

        Transfer.transferIn(asset, from, amount);

        Events.logDeposit(from, asset, amount);
    }

    function withdraw(
        uint256 amount
    )
        public
        nonReentrant
    {
        address to = msg.sender;
        address asset = state.collateralAsset;

        require(amount > 0, "Operations: withdraw amount must greater than zero");

        uint256 balance = state.collateralBalances[to];
        require(balance >= amount, "Operations: balance must greater than zero");

        state.collateralBalances[to] = state.collateralBalances[to].sub(amount);

        Transfer.transferOut(asset, to, amount);

        Events.logWithdraw(to, asset, amount);
    }

    function transfer(
        address to,
        uint256 amount
    )
        public
        nonReentrant
    {
        address from = msg.sender;
        address asset = state.collateralAsset;

        require(amount > 0, "Operations: transfer amount must greater than zero");

        uint256 balance = state.collateralBalances[from];
        require(balance >= amount, "Operations: balance must greater than zero");

        state.collateralBalances[from] = state.collateralBalances[from].sub(amount);
        state.collateralBalances[to] = state.collateralBalances[to].add(amount);

        Events.logTransfer(from, to, asset, amount);
    }
}