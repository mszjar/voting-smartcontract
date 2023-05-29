// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Voting is Ownable {
    mapping(address => Voter) internal voters; // Only registered voters can see the votes
    Proposal[] public proposals; // List of proposals
    uint public votingSessionStartTime; // Time set to inspire confidence, this avoids the owner to end the session before everyone has a chance to vote.
    uint public winningProposalId;

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }

    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    WorkflowStatus public status; // Status of the workflow


    // get WorkflowStatus
    function getWorkflowStatus() public view returns(string memory) {
        if (status == WorkflowStatus.RegisteringVoters) {
            return "RegisteringVoters";
        } else if (status == WorkflowStatus.ProposalsRegistrationStarted) {
            return "ProposalsRegistrationStarted";
        } else if (status == WorkflowStatus.ProposalsRegistrationEnded) {
            return "ProposalsRegistrationEnded";
        } else if (status == WorkflowStatus.VotingSessionStarted) {
            return "VotingSessionStarted";
        } else if (status == WorkflowStatus.VotingSessionEnded) {
            return "VotingSessionEnded";
        } else if (status == WorkflowStatus.VotesTallied) {
            return "VotesTallied";
        } else {
            return "Unknown";
        }
    }


    // Register voters
    function registerVoter(address _voterAddress) public onlyOwner {
        require(status == WorkflowStatus.RegisteringVoters, "Sorry, voters registration has ended.");
        require(!voters[_voterAddress].isRegistered, "Already in the voting list");

        voters[_voterAddress] = Voter({
            isRegistered: true,
            hasVoted: false,
            votedProposalId: 0
        });

        emit VoterRegistered(_voterAddress);
    }

    // Get votes
    function getVotes(address _voterAddress) public view returns(bool isRegistered, bool hasVoted, uint votedProposalId) {
        require(voters[msg.sender].isRegistered == true, "You are not allowed to see the votes");
        Voter memory voter = voters[_voterAddress];
        return (voter.isRegistered, voter.hasVoted, voter.votedProposalId);
    }


    // Start proposal registration
    function startProposalsRegistration() public onlyOwner {
        require(status == WorkflowStatus.RegisteringVoters, "Cannot start proposal registration yet");
        status = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted);
    }


    // Register proposals
    function registerProposal(string memory _description) public {
        require(status == WorkflowStatus.ProposalsRegistrationStarted, "Proposals registration hasn't started yet");
        require(voters[msg.sender].isRegistered == true, "Sorry, you are not in the voting list");
        proposals.push(Proposal({
            description: _description,
            voteCount: 0
        }));

        emit ProposalRegistered(proposals.length - 1);
    }

    // End proposal registration
    function endProposalsRegistration() public onlyOwner {
        require(status == WorkflowStatus.ProposalsRegistrationStarted, "The proposal registration hasn't started yet");
        require(proposals.length > 1, "At least two proposals are required before ending registration");
        status = WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, WorkflowStatus.ProposalsRegistrationEnded);
    }


    // Start voting session
    function startVotingSession() public onlyOwner {
        require(status == WorkflowStatus.ProposalsRegistrationEnded, "The proposal registration hasn't finished yet");
        status = WorkflowStatus.VotingSessionStarted;
        votingSessionStartTime = block.timestamp; // Store the time when the voting session started
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted);
    }

    // Vote for a proposal
    function vote(uint _proposalId) public {
        require(status == WorkflowStatus.VotingSessionStarted, "Voting session not started");
        require(voters[msg.sender].isRegistered, "Voter is not registered");
        require(!voters[msg.sender].hasVoted, "Voter has already voted");
        require(_proposalId < proposals.length, "Invalid proposal ID");

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedProposalId = _proposalId;

        proposals[_proposalId].voteCount++;

        emit Voted(msg.sender, _proposalId);
    }

    // End voting session
    function endVotingSession() public onlyOwner {
        require(block.timestamp >= votingSessionStartTime + 2 minutes, "Voting session must last at least two minutes"); // At least 2 minutes lasts the voting session
        require(status == WorkflowStatus.VotingSessionStarted, "The voting session hasn't started yet");
        status = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded);
    }

    // Tally votes
    function tallyVotes() public onlyOwner {
        require(status == WorkflowStatus.VotingSessionEnded, "The voting session has not ended yet");

        uint winningVoteCount = 0;
        uint winningProposalIndex = 0;

        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > winningVoteCount) {
                winningVoteCount = proposals[i].voteCount;
                winningProposalIndex = i;
            }
        }

        winningProposalId = winningProposalIndex;

        status = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);
    }

    // Get winner proposal
    function getWinningProposalDescription() public view returns (string memory, uint) {
        require(status == WorkflowStatus.VotesTallied, "Votes have not been tallied yet");
        return (proposals[winningProposalId].description, proposals[winningProposalId].voteCount);
    }


}
