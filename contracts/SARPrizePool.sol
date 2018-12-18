pragma solidity >=0.4.21 <0.6.0;

contract SARPrizePool {

    address private owner;
    uint private winnersCount;
    uint private frozenPrizePerShare;
    bool private frozen;

    uint private C;
    mapping ( address => bool ) private hasClaimed;
    mapping ( address => bool ) private winnerMap;

    event ClaimPrize(address winner, uint amount);
    event NewWinner(address winner);

    constructor(uint _C) public {
        C = _C;
        owner = msg.sender;
    }

    // Transfer Prize to Msg.sender
    function _transferPrize() internal;

    function claimPrize() public isFrozen {
        require(winnerMap[msg.sender], "You're not a winner");
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

    function canFreeze() internal view returns (bool);

    function freeze() public notFrozen {
        require(canFreeze(), "No permmission to freeze");
        frozen = true;
        frozenPrizePerShare = getCurrentPrizePerShare();
    }

    modifier isFrozen() {
        require(frozen, "Not frozen");
        _;
    }

    modifier notFrozen() {
        require(!frozen, "Frozen");
        _;
    }

    function addWinner(address winner) internal notFrozen {
        uint temp = winnersCount + 1;
        require(temp >= winnersCount, "Overflow");
        winnersCount = temp;
        winnerMap[winner] = true;
        emit NewWinner(winner);
    }

    function getFrozenPrizePerShare() public view isFrozen returns (uint) {
        return frozenPrizePerShare;
    }

    function getFrozenPrizePool() public view isFrozen returns (uint) {
        return winnersCount * frozenPrizePerShare;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    modifier isWinner {
        require(winnerMap[msg.sender], "You're not a winner!");
        _;    
    }

    modifier isNotWinner {
        require(!winnerMap[msg.sender], "You're already a winner!");
        _;
    }
}