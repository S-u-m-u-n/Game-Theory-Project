pragma solidity >=0.6.0 <0.7.0;

contract QuadraticVoting {
    uint256 public biddingEnd;
    uint256 public revealEnd;
    bool public ended;

    struct Voter {
        // arrays inside of structs are somehow weird? wtf
        uint256 numTokens;
        address voter;
        uint256[3] votedFor;
        uint256[3] numVotes;
    }

    struct Vote {
        bytes32 blindedVote;
        uint256 numTokens; // value transfers cannot be blinded in Ethereum => has to be visible to others
    }

    mapping(address => Vote[]) public votes;

    // allow vote-tokens to be redistributed?
    mapping(address => uint256) pendingVotes;

    // ToDo: listen to this event with Web 3.0 when it is fired
    // ToDo: add winner of the 3 voting options as paramters
    event VotingEnded();

    // The code for the function being modified is inserted where the _ is placed in the modifier.
    modifier onlyBefore(uint256 _time) {
        require(now < _time);
        _;
    }
    modifier onlyAfter(uint256 _time) {
        require(now > _time);
        _;
    }

    constructor(
        uint256 _biddingTime,
        uint256 _revealTime,
        uint256[3] winner
    ) public {
        // winner?
        biddingEnd = now + _biddingTime;
        revealEnd = biddingEnd + _revealTime;
    }

    // hidden voting
    function vote(bytes32 _blindedVote) public payable onlyBefore(biddingEnd) {}

    // reveal hidden votes
    function reveal() public onlyAfter(biddingEnd) onlyBefore(revealEnd) {}

    function votingEnd() public onlyAfter(revealEnd) {
        require(!ended);
        // ToDo: add parameters / figure out who won the Voting
        emit VotingEnded();
        ended = true;
        // the rest should be handled by the frontend
    }
}
