# Projet - Système de vote
Un smart contract de vote peut être simple ou complexe, selon les exigences des élections que vous souhaitez soutenir. Le vote peut porter sur un petit nombre de propositions (ou de candidats) présélectionnées, ou sur un nombre potentiellement important de propositions suggérées de manière dynamique par les électeurs eux-mêmes.

Dans ce cadres, vous allez écrire un smart contract de vote pour une petite organisation. Les électeurs, que l'organisation connaît tous, sont inscrits sur une liste blanche (whitelist) grâce à leur adresse Ethereum, peuvent soumettre de nouvelles propositions lors d'une session d'enregistrement des propositions, et peuvent voter sur les propositions lors de la session de vote.

✔️ Le vote n'est pas secret pour les utilisateurs ajoutés à la Whitelist
✔️ Chaque électeur peut voir les votes des autres
✔️ Le gagnant est déterminé à la majorité simple
✔️ La proposition qui obtient le plus de voix l'emporte.
✔️ N'oubliez pas que votre code doit inspirer la confiance et faire en sorte de respecter les ordres déterminés!


👉 Le processus de vote :

Voici le déroulement de l'ensemble du processus de vote :

L'administrateur du vote enregistre une liste blanche d'électeurs identifiés par leur adresse Ethereum.
L'administrateur du vote commence la session d'enregistrement de la proposition.
Les électeurs inscrits sont autorisés à enregistrer leurs propositions pendant que la session d'enregistrement est active.
L'administrateur de vote met fin à la session d'enregistrement des propositions.
L'administrateur du vote commence la session de vote.
Les électeurs inscrits votent pour leur proposition préférée.
L'administrateur du vote met fin à la session de vote.
L'administrateur du vote comptabilise les votes.
Tout le monde peut vérifier les derniers détails de la proposition gagnante.


👉 Les recommandations et exigences :

Votre smart contract doit s’appeler “Voting”.
Votre smart contract doit utiliser la dernière version du compilateur.
L’administrateur est celui qui va déployer le smart contract.
Votre smart contract doit définir les structures de données suivantes :
struct Voter {
bool isRegistered;
bool hasVoted;
uint votedProposalId;
}
struct Proposal {
string description;
uint voteCount;
}
Votre smart contract doit définir une énumération qui gère les différents états d’un vote
enum WorkflowStatus {
RegisteringVoters,
ProposalsRegistrationStarted,
ProposalsRegistrationEnded,
VotingSessionStarted,
VotingSessionEnded,
VotesTallied
}
Votre smart contract doit définir un uint winningProposalId qui représente l’id du gagnant ou une fonction getWinner qui retourne le gagnant.
Votre smart contract doit importer le smart contract la librairie “Ownable” d’OpenZepplin.
Votre smart contract doit définir les événements suivants :
event VoterRegistered(address voterAddress);
event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
event ProposalRegistered(uint proposalId);
event Voted (address voter, uint proposalId);

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
