const { expect } = require('chai');

describe('Voting', function () {
  let Voting, voting, owner, addr1, addr2, addrs;

  beforeEach(async function () {
    Voting = await ethers.getContractFactory('Voting');
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    voting = await Voting.deploy();
  });

  describe('Deployment', function () {
    it('Should set the right owner', async function () {
      expect(await voting.owner()).to.equal(owner.address);
    });

    it('Should set the initial WorkflowStatus correctly', async function () {
      expect(await voting.workflowStatus()).to.equal(0);
    });

    it('Should initialize with Genesis proposal', async function () {
      expect(await voting.getOneProposal(0)).to.deep.equal(["GENESIS", 0]);
    });
  });

  describe('Registration', function () {
    it('Should allow owner to add voters', async function () {
      await voting.connect(owner).addVoter(addr1.address);
      let voter = await voting.getVoter(addr1.address);
      expect(voter.isRegistered).to.equal(true);
      expect(voter.hasVoted).to.equal(false);
    });

    it('Should not allow non-owners to add voters', async function () {
      await expect(voting.connect(addr1).addVoter(addr2.address)).to.be.revertedWith("Ownable: caller is not the owner");
    });

    it('Should not allow adding voter twice', async function () {
      await voting.connect(owner).addVoter(addr1.address);
      await expect(voting.connect(owner).addVoter(addr1.address)).to.be.revertedWith('Already registered');
    });

    it('Should not allow adding voter in wrong state', async function () {
      await voting.connect(owner).startProposalsRegistering();
      await expect(voting.connect(owner).addVoter(addr1.address)).to.be.revertedWith('Voters registration is not open yet');
    });
  });

  describe('Proposals', function () {
    beforeEach(async function () {
      await voting.connect(owner).addVoter(addr1.address);
      await voting.connect(owner).startProposalsRegistering();
    });

    it('Should allow voters to add proposals', async function () {
      await voting.connect(addr1).addProposal("Test Proposal");
      let proposal = await voting.getOneProposal(1);
      expect(proposal.description).to.equal("Test Proposal");
      expect(proposal.voteCount).to.equal(0);
    });

    it('Should not allow non-voters to add proposals', async function () {
      await expect(voting.connect(addr2).addProposal("Test Proposal")).to.be.revertedWith("You're not a voter");
    });

    it('Should not allow adding proposal in wrong state', async function () {
      await voting.connect(owner).endProposalsRegistering();
      await expect(voting.connect(addr1).addProposal("Test Proposal")).to.be.revertedWith('Proposals are not allowed yet');
    });

    it('Should not allow adding empty proposal', async function () {
      await expect(voting.connect(addr1).addProposal("")).to.be.revertedWith('Vous ne pouvez pas ne rien proposer');
    });
  });

  describe('Voting', function () {
    beforeEach(async function () {
      await voting.connect(owner).addVoter(addr1.address);
      await voting.connect(owner).addVoter(addr2.address);
      await voting.connect(owner).startProposalsRegistering();
      await voting.connect(addr1).addProposal("Test Proposal");
      await voting.connect(addr2).addProposal("Test Proposal 2");
      await voting.connect(owner).endProposalsRegistering();
      await voting.connect(owner).startVotingSession();
    });

    it('Should allow voters to vote', async function () {
      await voting.connect(addr1).setVote(1);
      let voter = await voting.getVoter(addr1.address);
      expect(voter.hasVoted).to.equal(true);
      expect(voter.votedProposalId).to.equal(1);
      let proposal = await voting.getOneProposal(1);
      expect(proposal.voteCount).to.equal(1);
    });

    it('Should not allow non-voters to vote', async function () {
      await expect(voting.connect(addrs[0]).setVote(1)).to.be.revertedWith("You're not a voter");
    });

    it('Should not allow voting twice', async function () {
      await voting.connect(addr1).setVote(1);
      await expect(voting.connect(addr1).setVote(1)).to.be.revertedWith('You have already voted');
    });

    it('Should not allow voting on non-existent proposal', async function () {
      await expect(voting.connect(addr1).setVote(3)).to.be.revertedWith('Proposal not found');
    });

    it('Should not allow voting in wrong state', async function () {
      await voting.connect(owner).endVotingSession();
      await expect(voting.connect(addr1).setVote(1)).to.be.revertedWith('Voting session havent started yet');
    });
  });

  describe('Workflow', function () {
    it('Should follow correct workflow', async function () {
      await voting.connect(owner).addVoter(addr1.address);
      await voting.connect(owner).addVoter(addr2.address);
      await voting.connect(owner).startProposalsRegistering();
      await voting.connect(addr1).addProposal("Test Proposal");
      await voting.connect(addr2).addProposal("Test Proposal 2");
      await voting.connect(owner).endProposalsRegistering();
      await voting.connect(owner).startVotingSession();
      await voting.connect(addr1).setVote(1);
      await voting.connect(addr2).setVote(2);
      await voting.connect(owner).endVotingSession();
      await voting.connect(owner).tallyVotes();
      expect(await voting.winningProposalID()).to.equal(2);
    });

    it('Should not allow changing to wrong state', async function () {
      await expect(voting.connect(owner).startVotingSession()).to.be.revertedWith('Registering proposals phase is not finished');
    });

    it('Should not allow non-owner to change state', async function () {
      await expect(voting.connect(addr1).startProposalsRegistering()).to.be.revertedWith("Ownable: caller is not the owner");
    });
  });
});
