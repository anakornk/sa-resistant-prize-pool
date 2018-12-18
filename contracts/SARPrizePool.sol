pragma solidity >=0.4.21 <0.6.0;

contract SARPrizePool {

    address public owner;
    uint public winnersCount;
    uint public frozenPrizePerShare;
    bool public isFrozen;

    uint internal C;
    mapping ( address => bool ) hasClaimed;
    mapping ( address => bool ) isWinner;

    event ClaimPrize(address user, uint amount);

    constructor(uint _C) public {
        C = _C;
        owner = msg.sender;
    }

    // Transfer Prize to Msg.sender
    function _transferPrize() internal;

    function claimPrize() public {
        require(isFrozen, "Winners list is not frozen");
        require(isWinner[msg.sender], "You're not a winner");
        require(hasClaimed[msg.sender] == false, "You have claimed the prize already");
        hasClaimed[msg.sender] = true;
        _transferPrize();
        emit ClaimPrize(msg.sender, frozenPrizePerShare);
    }

    function getInitialPrizePool() public view returns (uint);

    function getCurrentPrizePerShare() public view returns (uint) {
        return (getInitialPrizePool() / 2 ** (winnersCount-1)) - C;
    }

    function getCurrentPrizePool() public view returns (uint) {
        return winnersCount * getCurrentPrizePerShare();
    }

    function canFreeze() internal returns (bool);

    function freeze() public {
        require(canFreeze(), "No permmission to freeze");
        isFrozen = true;
        frozenPrizePerShare = getCurrentPrizePerShare();
    }
}


contract ETHPrizePool is SARPrizePool {

    constructor(uint _C) public SARPrizePool(_C) {
    }

    function () external payable {}   

    function getInitialPrizePool() public view returns (uint) {
        return address(this).balance;
    }

    // Transfer prize to msg.sender
    function _transferPrize() internal {
        msg.sender.transfer(frozenPrizePerShare);
    }
}

contract SimpleSumGame is ETHPrizePool {
    uint public sum;

    event SubmitAnswer(address user, uint a, uint b, bool correct);

    constructor(uint _sum) public ETHPrizePool(1) {
        sum = _sum;
    }

    modifier isNotWinner {
        require(!isWinner[msg.sender], "You're already a winner!");
        _;
    }

    function submitAnswer(uint _a, uint _b) public isNotWinner {
        if (_a + _b == sum) {
            uint temp = winnersCount + 1;
            require(temp >= winnersCount, "Overflow");
            winnersCount = temp;
            isWinner[msg.sender] = true;
            emit SubmitAnswer(msg.sender, _a, _b, true);
        }  else {
            emit SubmitAnswer(msg.sender, _a, _b, false);
        }
    }

    function canFreeze() internal returns (bool) {
        return msg.sender == owner;
    }
}