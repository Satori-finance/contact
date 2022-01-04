pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./Types.sol";

library Events {
    // ============ Events ============

    event LogDeposit(
        address indexed account,
        address asset,
        uint256 amount
    );

    event LogWithdraw(
        address indexed account,
        address asset,
        uint256 amount
    );

    event LogTransfer(
        address indexed from,
        address indexed to,
        address asset,
        uint256 amount
    );

    event CreateMarket(Types.Market market);
    event UpdateMarket(Types.Market market);

    event DepositForRisk(address indexed from, uint256 amount);
    event WithdrawFromRisk(uint256 amount);

    event IncreaseCollateral(address indexed from, uint256 amount, bytes32 orderHash);

    event DecreaseCollateral(address indexed from, uint256 amount, bytes32 orderHash);
    // ============ Structs ============

    // ============ Internal Functions ============

    function logDeposit(
        address account,
        address asset,
        uint256 amount
    )
    internal
    {
        emit LogDeposit(
            account,
            asset,
            amount
        );
    }

    function logWithdraw(
        address account,
        address asset,
        uint256 amount
    )
    internal
    {
        emit LogWithdraw(
            account,
            asset,
            amount
        );
    }

    function logTransfer(
        address from,
        address to,
        address asset,
        uint256 amount
    )
    internal
    {
        emit LogTransfer(
            from,
            to,
            asset,
            amount
        );
    }


    function increaseOrDecreaseCollateral(
        Types.Wei  memory amount,
        bytes32 orderHash,
        address account
    )
    internal
    {
        if (amount.sign) {
            emit IncreaseCollateral(account, amount.value, orderHash);
        } else {
            emit DecreaseCollateral(account, amount.value, orderHash);
        }
    }

    function logCreateMarket(
        Types.Market memory market
    )
    internal
    {
        emit CreateMarket(market);
    }

    function logUpdateMarket(
        Types.Market memory market
    )
    internal
    {
        emit UpdateMarket(market);
    }

    function depositForRisk(
        address from,
        uint256 amount
    )
    internal
    {
        emit DepositForRisk(from, amount);
    }

    function withdrawFromRisk(
        uint256 amount
    )
    internal
    {
        emit WithdrawFromRisk(amount);
    }







    // ============ Private Functions ============

}
