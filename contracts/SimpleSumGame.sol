pragma solidity >=0.4.21 <0.6.0;

import "./ETHPrizePool.sol";

contract SimpleSumGame is ETHPrizePool {
    uint public sum;

    constructor(uint _sum) public ETHPrizePool(1) {
        sum = _sum;
    }

    function submitAnswer(uint _a, uint _b) public isNotWinner {
        if (_a + _b == sum) {
            addWinner(msg.sender);
        } 
    }

    function canFreeze() internal view returns (bool) {
        return msg.sender == getOwner();
    }
}