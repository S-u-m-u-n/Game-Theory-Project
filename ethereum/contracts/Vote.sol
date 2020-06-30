pragma solidity >=0.6.10 <0.7.0;

contract QuadraticVoting {
    uint256 public biddingEnd;
    uint256 public revealEnd;
    bool public ended;

    // for simplicity's sake we assume that there is only one winner per question
    // one would handle multiple voters by storing the winners in an array
    address public winnerQuestion1;
    address public winnerQuestion2;
    address public winnerQuestion3;
    uint public highestVotes1;
    uint public highestVotes2;
    uint public highestVotes3;

    struct Voter {
        string voterName;
        uint256 numTokens;
        address voter;
        address votedForQuestion1; // address of e.g. "Von Neumann"
        address votedForQuestion2;
        address votedForQuestion3;

        uint256 numVotesQuestion1; // how many token a voter uses to vote
        uint256 numVotesQuestion2;
        uint256 numVotesQuestion3;
    }

    struct Vote {
        bytes32 blindedVote; // a hashed version of the voter's choice, s.t. others do not know what the voter voted for
        uint256 voteCount; // value transfers cannot be blinded in Ethereum => has to be visible to others
    }

    mapping(address => Vote[]) public votes;

    // listen to this event with Web 3.0 when it is fired, adapt frontend.
    // The frontend handles all print statements that we included in the other version
    // of the Quadratic Voting smart contract 
    event VotingEnded(address winnerQ1, address winnerQ2, address winnerQ3);

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
        // for simplicity's sake we assume that there is only one winner per question
        // one would handle multiple voters by storing the winners in an array
        address[] Question1Votes,
        address[] Question2Votes,
        address[] Question3Votes
    ) public {
        // winner?
        biddingEnd = now + _biddingTime;
        revealEnd = biddingEnd + _revealTime;
    }

    // hidden voting
    // Place a blinded vote with `_blindedVote` = keccak256(abi.encodePacked(value))
    function vote(bytes32 _blindedVote) public payable onlyBefore(biddingEnd) {
        votes[msg.sender].push(Vote({
            blindedVote: _blindedVote,
            voteCount: msg.value
        }));
    }

    // reveal hidden votes
    function reveal(uint[] memory values) public onlyAfter(biddingEnd) onlyBefore(revealEnd) {
        length = votes[msg.sender].length;
        for (uint i = 0; i < length; ++i) {
            Vote storage vote = votes[msg.sender][i];
            if(vote.blindedVote != keccak256(abi.encodePacked(value))) {
                continue;
            }
            // send tokens to the address of the option the user voted for (omitted)
        }
    }

    function votingEnd() public onlyAfter(revealEnd) {
        require(!ended);
        // figure out who won the Voting... (omitted for simplicity's sake)
        // ...and then fire an event that the frontend can listen to
        emit VotingEnded(winnerQuestion1, winnerQuestion2, winnerQuestion3);
        ended = true;
        // The rest is handled by the frontend as mentioned above
    }
}
