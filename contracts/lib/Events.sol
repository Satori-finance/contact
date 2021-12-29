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

    //TODO
    event LogTrade(
        address indexed account,
        uint256 amount
    );

    event CreateMarket(Types.Market market);
    event DepositForRisk(address indexed from, uint256 amount);
    event WithdrawFromRisk(uint256 amount);

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

    //TODO
    function logTrade(
        address account,
        uint256 amount
    )
        internal
    {
        emit LogTrade(
            account,
            amount
        );
    }

    function logCreateMarket(
        Types.Market memory market
    )
        internal
    {
        emit CreateMarket(market);
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
