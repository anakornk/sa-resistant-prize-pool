pragma solidity >=0.4.21 <0.6.0;
import "./SafeMath.sol";

contract SARPrizePool {
    using SafeMath for uint;

    address payable private owner;
    uint private winnersCount;
    uint private frozenPrizePerShare;
    bool private frozen;
    uint private claimsCount;

    uint private C;
    mapping ( address => bool ) private hasClaimed;
    mapping ( address => bool ) private winnerMap;

    event ClaimPrize(address winner, uint amount);
    event NewWinner(address winner);

    constructor(uint _C) public {
        C = _C;
        owner = msg.sender;
    }

    function _transferPrize(address payable to, uint amount) internal;

    function claimPrize() public isFrozen {
        require(winnerMap[msg.sender], "You're not a winner");
        require(hasClaimed[msg.sender] == false, "You have claimed the prize already");
        hasClaimed[msg.sender] = true;
        claimsCount = claimsCount.add(1);
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
        // DO NOT CHANGE THE ORDER BELOW
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
        winnersCount = winnersCount.add(1);
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

    function getClaimsCount() public view returns (uint) {
        return claimsCount;
    }

    function getLeftovers() public view returns (uint leftovers) {
        uint claimablePrize = (winnersCount - claimsCount) * frozenPrizePerShare;
        leftovers = getPrizePool().sub(claimablePrize);
        assert(leftovers >= 0);
    }

    function refundLeftovers() public isOwner returns (uint leftovers) {
        leftovers = getLeftovers();
        _transferPrize(owner, leftovers);
    }
}