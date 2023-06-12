# Voting Testing

This test suite ensures the proper functioning of the Voting DApp contract. All functionalities, including deployment, registration, proposal addition, voting, and the overall workflow, are tested.

## Test Breakdown

1. **Deployment Tests**: These tests ensure that the contract is properly deployed, the owner is correctly set, and the initial state of the contract is as expected (initial WorkflowStatus and the "Genesis" proposal).

2. **Registration Tests**: These tests validate the process of adding voters. They check that only the owner can add voters, each address can be registered only once as a voter, and that registration can only occur during the correct state.

3. **Proposal Tests**: These tests check the proposal addition feature. They validate that only registered voters can add proposals, proposals can only be added during the correct state, and that empty proposals cannot be added.

4. **Voting Tests**: These tests validate the voting mechanism. They confirm that only registered voters can vote, each voter can only vote once, voters can only vote for existing proposals, and that voting can only occur during the correct state.

5. **Workflow Tests**: These tests ensure the contract follows the correct workflow. They verify the process of state transitions and validate that only the owner can change the state. They also test the full election workflow from voter registration to the tallying of votes.

The tests are designed to ensure that all features and functionalities of the Voting DApp contract work as expected and handle edge cases gracefully. They also serve to confirm that the contract enforces the necessary restrictions on user actions based on the contract's state and user's role (owner or voter).

The tests use the [Chai library](https://www.chaijs.com/) with the [Ethers.js](https://docs.ethers.io/v5/) library, which provides a set of utilities to interact with Ethereum and its smart contracts.

## How to Run Tests

To run these tests, you will need to install the necessary dependencies, including ethers.js and hardhat. Once the dependencies are installed, you can run the tests using the `npx hardhat test` command from the root directory of the project. The test results will be displayed in the console.

The test suite ensures comprehensive coverage of the contract's functionalities, helping to maintain its integrity and reliability as it evolves.
