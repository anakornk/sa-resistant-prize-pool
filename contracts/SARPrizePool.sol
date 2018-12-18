pragma solidity >=0.4.21 <0.6.0;

contract SARPrizePool {

    address payable private owner;
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
    function _transferPrize(address payable to, uint amount) internal;

    function claimPrize() public isFrozen {
        require(winnerMap[msg.sender], "You're not a winner");
        require(hasClaimed[msg.sender] == false, "You have claimed the prize already");
        hasClaimed[msg.sender] = true;
        _transferPrize(msg.sender, getCurrentPrizePerShare());
        emit ClaimPrize(msg.sender, frozenPrizePerShare);
    }

    function getPrizePool() public view returns (uint);

    function getCurrentPrizePerShare() public view returns (uint) {
        if(frozen) {
            return frozenPrizePerShare;
        } else {
            return (getPrizePool() / 2 ** (winnersCount-1)) - C;
        }
    }

    function getCurrentPrizePool() public view returns (uint) {
        return winnersCount * getCurrentPrizePerShare();
    }

    function _canFreeze() internal view returns (bool);

    function freeze() public notFrozen {
        require(_canFreeze(), "No permmission to freeze");
        // order is important here
        frozenPrizePerShare = getCurrentPrizePerShare();
        frozen = true;
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

    modifier isOwner {
        require(msg.sender == owner, "You're not the owner");
        _;
    }

    function checkWinner(address winner) public view returns (bool) {
        return winnerMap[winner];
    }

    function checkFrozen() public view returns (bool) {
        return frozen;
    }

    function getWinnersCount() public view returns (uint) {
        return winnersCount;
    }

    function refundLeftovers() public returns (uint leftovers) {
        // TODO: COMPUTE LEFTOVERS
        leftovers = 5;
        _transferPrize(owner, leftovers);
    }
}