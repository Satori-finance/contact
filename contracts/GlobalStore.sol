pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./lib/Store.sol";

contract GlobalStore {
    Store.State state;
}