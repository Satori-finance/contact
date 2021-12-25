
pragma solidity ^0.6.0;
// pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/access/Ownable.sol';

import "../interfaces/IOracle.sol";

contract Oracle is IOracle, Ownable {
    address public setter;
    mapping(address => uint256) public prices;

    constructor(address _setter) public {
        setter = _setter;
    }

    modifier onlySetter() {
        require(msg.sender == setter, "Oracle: not setter");

        _;
    }

    function updateSetter(address _setter) public onlyOwner {
        require(_setter != address(0), "Oracle: invalid new setter");
        setter = _setter;
    }

    function updatePrices(
        address[] calldata _assets,
        uint256[] calldata _prices
    )
        public
        onlySetter
    {
        require(_assets.length > 0, "Oracle: length must greater than zero");
        require(_assets.length == _prices.length, "Oracle: invalid length");

        for(uint i = 0; i < _assets.length; i++) {
            address asset = _assets[i];
            uint256 price = _prices[i];
            require(asset != address(0), "Oracle: invalid asset");
            prices[asset] = price;
        }
    }

    function getPrice(
        address asset
    )
        override
        public
        view 
        returns (uint256)
    {
        return prices[asset];
    }
}