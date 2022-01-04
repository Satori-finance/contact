pragma solidity ^0.6.0;

/**
 * EIP712 Ethereum typed structured data hashing and signing
 */
library Consts {
    //10% = 0.1 = 10000 / 100000 
    function Denominator()
        internal
        pure
        returns (uint256)
    {
        return 100000;
    }
}

