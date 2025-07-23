# LIP/LRC Glossary

This glossary defines key terms used throughout the Lux Improvement Proposal documentation and process.

## A

**A-Chain (Archive Chain)**  
A specialized blockchain in the Lux Network designed for long-term data storage and archival. Enables efficient data availability and historical state access.

**Abstract**  
A brief (~200 word) summary of a LIP that describes the technical issue being addressed. Required section in all LIPs.

**Account Abstraction**  
The concept of making accounts programmable, allowing smart contract wallets with custom validation logic. See LRC-4337.

**ACP (Avalanche Community Proposal)**  
The equivalent of LIPs in the Avalanche ecosystem. Lux drew inspiration from this model.

**Application Standards**  
Standards that define application-layer protocols, typically categorized as LRCs (Lux Request for Comments).

**Attestation**  
A cryptographic proof or statement about data or identity, primarily used on the B-Chain for compliance and verification.

**AWM (Avalanche Warp Messaging)**  
Cross-subnet messaging protocol that Lux adapted as Teleporter for cross-chain communication.

## B

**B-Chain (Attestation Blockchain)**  
A specialized blockchain in the Lux Network focused on attestations, compliance, and identity management.

**Backwards Compatibility**  
The property of a system to work with older versions. LIPs must address backwards compatibility concerns.

**BLS Signatures**  
Boneh-Lynn-Shacham signatures that allow efficient signature aggregation, used in B-Chain for attestations.

**Bridge**  
Infrastructure that enables asset transfers between different blockchains. See LIP-17 for universal bridge standards.

## C

**C-Chain (Contract Chain)**  
The EVM-compatible blockchain in Lux Network where smart contracts are deployed.

**Category**  
Classification within Standards Track LIPs: Core, Networking, Interface, or LRC.

**CC0**  
Creative Commons Zero - public domain dedication under which all LIPs are released.

**Consensus**  
The mechanism by which network participants agree on the state of the blockchain.

**Core**  
Category of Standards Track LIPs that affect consensus, block validation, or other low-level protocol changes.

**Cross-chain**  
Refers to interactions between different blockchains, a key focus of Phase 3 development.

## D

**DAS (Data Availability Sampling)**  
Technique for verifying data availability without downloading all data, implemented in Phase 6.

**DeFi (Decentralized Finance)**  
Financial applications built on blockchain technology, including lending, trading, and yield generation.

**Draft**  
Initial status of a LIP when first submitted.

## E

**Editor**  
Community members responsible for managing the LIP repository and guiding authors through the process.

**EIP (Ethereum Improvement Proposal)**  
The Ethereum equivalent of LIPs, which served as inspiration for the LIP process.

**ERC (Ethereum Request for Comments)**  
Application-layer standards in Ethereum, equivalent to LRCs in Lux.

**EVM (Ethereum Virtual Machine)**  
The runtime environment for smart contracts, which Lux C-Chain is compatible with.

## F

**Final**  
The terminal status for accepted LIPs that have been implemented and adopted.

**Finality**  
The guarantee that a transaction cannot be reversed or altered.

**Fork**  
A change to protocol rules. Can be hard (breaking) or soft (backward compatible).

**Fungible Token**  
Tokens where each unit is interchangeable with another, standardized in LRC-20.

## G

**Gas**  
The unit of computational effort required to execute operations on the network.

**Governance**  
The process by which decisions are made about protocol changes and ecosystem direction.

## H

**Hard Fork**  
A protocol change that is not backward compatible, requiring all nodes to upgrade.

**Holographic Consensus**  
A scalable governance mechanism implemented in Lux that enables efficient decision-making.

## I

**Implementation**  
Working code that demonstrates how a LIP specification functions in practice.

**Informational**  
Type of LIP that provides guidelines or information but doesn't require implementation.

**Interface**  
Category of Standards Track LIPs dealing with API/RPC specifications and standards.

**Interoperability**  
The ability of different blockchain systems to exchange and make use of information.

## L

**Last Call**  
The final review period (14 days) before a LIP moves to Final status.

**Light Client**  
A client that can verify blockchain data without storing the entire chain history.

**LIP (Lux Improvement Proposal)**  
The primary mechanism for proposing changes to the Lux Network.

**LRC (Lux Request for Comments)**  
A subcategory of Standards Track LIPs focused on application-layer standards.

**LUX**  
The native token of the Lux Network.

## M

**Meta**  
Type of LIP dealing with process, governance, or other non-technical changes.

**Multi-sig (Multi-signature)**  
Requiring multiple signatures to authorize a transaction.

## N

**Networking**  
Category of Standards Track LIPs dealing with p2p protocols and network communication.

**NFT (Non-Fungible Token)**  
Unique tokens that cannot be exchanged on a 1:1 basis, standardized in LRC-721.

**Nullifier**  
A value that prevents double-spending in privacy protocols, used in Z-Chain.

## P

**P-Chain (Platform Chain)**  
The metadata blockchain in Lux that coordinates validators and manages subnets.

**Phase**  
One of seven major development stages in the Lux roadmap.

**Privacy**  
The ability to transact without revealing transaction details, enabled by Z-Chain.

**Proof of Stake**  
Consensus mechanism where validators stake tokens to participate in block production.

## Q

**Quorum**  
The minimum number of participants required for a governance decision.

## R

**Reference Implementation**  
Example code showing how to implement a LIP specification.

**Rejected**  
Status for LIPs that were not accepted by the community.

**Review**  
Status indicating a LIP is ready for community review and feedback.

## S

**Security Considerations**  
Required section in all LIPs addressing potential security implications.

**Shielded Pool**  
A privacy mechanism where funds are mixed to obscure transaction trails.

**Slashing**  
Penalty mechanism for validators who violate protocol rules.

**Smart Contract**  
Self-executing code deployed on the blockchain.

**Stagnant**  
Status for LIPs that have had no activity for 60+ days.

**Standards Track**  
Type of LIP that defines technical standards requiring implementation.

**State Rent**  
Economic mechanism where storage on the blockchain requires ongoing payment.

**Subnet**  
An independent blockchain network within the Lux ecosystem.

## T

**Teleporter**  
Lux's implementation of cross-chain messaging, based on AWM.

**Template**  
The required format for submitting new LIPs.

**Test Cases**  
Required examples showing how an implementation should behave.

**Testnet**  
A test version of the network used for development and testing.

**TPS (Transactions Per Second)**  
Measure of blockchain throughput and scalability.

**Type**  
Top-level classification of LIPs: Standards Track, Meta, or Informational.

## V

**Validator**  
A node that participates in consensus by validating transactions and producing blocks.

**Vault**  
A smart contract that manages deposited assets, standardized in LRC-4626.

**View Key**  
A key that allows viewing private transactions without spending ability.

## W

**Wallet**  
Software or hardware that stores private keys and enables blockchain interactions.

**Withdrawn**  
Status for LIPs that have been withdrawn by their authors.

**Wrapped Token**  
A token that represents another token, often from a different blockchain.

## X

**X-Chain (Exchange Chain)**  
The UTXO-based blockchain in Lux for simple value transfers.

## Z

**Z-Chain (Zero-knowledge Chain)**  
The privacy-focused blockchain in Lux Network using zero-knowledge proofs.

**Zero-Knowledge Proof**  
Cryptographic method to prove knowledge of information without revealing the information itself.

**zk-SNARK**  
Zero-Knowledge Succinct Non-Interactive Argument of Knowledge - a type of zero-knowledge proof.

---

## Acronym Quick Reference

- **ABI**: Application Binary Interface
- **AMM**: Automated Market Maker
- **API**: Application Programming Interface
- **DAO**: Decentralized Autonomous Organization
- **DEX**: Decentralized Exchange
- **KYC**: Know Your Customer
- **RPC**: Remote Procedure Call
- **SDK**: Software Development Kit
- **TVL**: Total Value Locked
- **UTXO**: Unspent Transaction Output

---

*This glossary is continuously updated as new terms emerge in the Lux ecosystem.*  
*Last Updated: January 2025*