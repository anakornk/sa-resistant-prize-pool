pragma solidity >=0.4.21 <0.6.0;

import "./SARPrizePool.sol";

contract ETHPrizePool is SARPrizePool {

    constructor(uint _C) public SARPrizePool(_C) {
    }

    function () external payable {}   

    function getPrizePool() public view returns (uint) {
        return address(this).balance;
    }

    // Transfer prize to msg.sender
    function _transferPrize(address payable to, uint amount) internal {
        to.transfer(amount);
    }
}