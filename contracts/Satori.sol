pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/math/Math.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';

import "./GlobalStore.sol";
import "./Operations.sol";
import "./Admin.sol";
import "./Getter.sol";
import "./Exchange.sol";

contract Satori is
    GlobalStore,
    Admin,
    Operations,
    Exchange,
    Getter
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    constructor(
        address collateralAsset
    ) public {
        state.collateralAsset = collateralAsset;
    }
}