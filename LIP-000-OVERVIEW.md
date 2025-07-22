# LIP-000: Lux Network Architecture Overview

**LIP Number**: 000  
**Title**: Comprehensive Lux Network Architecture  
**Author**: Lux Network Team  
**Status**: Final  
**Type**: Meta  
**Created**: 2025-01-01  
**Updated**: 2025-01-22

## Abstract

This meta-LIP provides a comprehensive overview of the Lux Network architecture, consisting of the Primary Network (P-Chain, X-Chain, C-Chain) with integrated bridge functionality and Z-Chain (Zero-Knowledge Chain) for privacy, cryptographic proofs, and omnichain attestations.

## Motivation

As the Lux Network evolves to support advanced cross-chain operations, privacy features, and AI/ML workloads, a clear architectural overview helps developers, validators, and users understand how all components work together.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Lux Network Architecture                      │
├───────────────────────────────────────────────────────────────────────┤
│                          Primary Network                              │
├─────────────────────┬─────────────────────┬─────────────────────────┤
│      P-Chain       │      X-Chain         │       C-Chain           │
│    (Platform)      │    (Exchange)        │     (Contract)          │
├─────────────────────┼─────────────────────┼─────────────────────────┤
│ • Validators       │ • UTXO Model         │ • EVM Compatible        │
│ • Subnets          │ • Asset Transfers    │ • Smart Contracts       │
│ • Staking          │ • Settlement Layer   │ • DeFi Ecosystem        │
└─────────────────────┴─────────────────────┴─────────────────────────┘
                                │
                    ┌───────────┴────────────┐
                    │   Specialized Chains   │
        ┌───────────┴────────┐      ┌────────┴───────────┐
        │     M-Chain         │      │     Z-Chain        │
        │  (Money/MPC Chain)  │◄────►│  (Zero-Knowledge)  │
        ├─────────────────────┤      ├────────────────────┤
        │ • CGG21 MPC         │      │ • zkEVM/zkVM       │
        │ • Asset Bridges     │      │ • FHE Operations   │
        │ • Teleport Protocol │      │ • Privacy Proofs   │
        │ • X-Chain Settlement│      │ • AI Attestations  │
        └─────────────────────┘      └────────────────────┘
```

## Chain Specifications

### Primary Network

#### P-Chain (Platform Chain)
- **Purpose**: Network coordination and governance
- **Features**: Validator management, subnet creation, staking operations
- **Consensus**: Snowman (linear chain)

#### X-Chain (Exchange Chain)
- **Purpose**: High-speed asset transfers and settlement
- **Features**: UTXO model, native asset creation, settlement layer for M-Chain
- **Consensus**: Avalanche (DAG)

#### C-Chain (Contract Chain)
- **Purpose**: EVM-compatible smart contracts
- **Features**: Ethereum compatibility, DeFi ecosystem, NFTs
- **Consensus**: Snowman with Ethereum block format

### Specialized Chains

#### M-Chain (Money/MPC Chain) - [LIP-001](./LIP-001-M-CHAIN.md)
- **Purpose**: Secure cross-chain asset management
- **Key Features**:
  - CGG21 threshold MPC (67/100 validators)
  - Teleport Protocol for native transfers
  - X-Chain settlement integration
  - Bridge governance
- **Validators**: Top 100 stakers who opt-in

#### Z-Chain (Zero-Knowledge Chain) - [LIP-002](./LIP-002-Z-CHAIN.md)
- **Purpose**: Privacy and cryptographic proofs
- **Key Features**:
  - zkEVM for private smart contracts
  - FHE for encrypted computation
  - zkBridge for private transfers
  - AI/ML model attestations
- **Validators**: Subset of M-Chain validators with specialized hardware

## Key Protocols

### 1. Teleport Protocol (M-Chain)

Enables native cross-chain asset transfers without wrapped tokens:

```
User Intent → M-Chain MPC Lock → X-Chain Settlement → Destination Release
```

**Benefits**:
- No wrapped tokens
- Native assets on destination
- Atomic execution
- Minimal fees

### 2. zkBridge Protocol (Z-Chain)

Provides privacy-preserving cross-chain transfers:

```
Shield Assets → Generate ZK Proof → Private Transfer → Unshield (Optional)
```

**Benefits**:
- Complete privacy
- Compliance hooks
- Selective disclosure
- Cross-chain privacy

### 3. Settlement Protocol (X-Chain)

All cross-chain operations settle through X-Chain:

```
Asset Entry: External Chain → M-Chain → X-Chain (Mint)
Asset Exit: X-Chain (Burn) → M-Chain → External Chain
```

**Benefits**:
- Unified liquidity
- Fast finality
- Simple accounting
- Native integration

## Validator Architecture

### Validator Tiers

1. **Primary Validators** (2000+ LUX)
   - Validate Primary Network only
   - Basic hardware requirements

2. **M-Chain Validators** (1,000,000+ LUX)
   - Top 100 validators by stake
   - Run MPC nodes
   - Share bridge fees

3. **Z-Chain Validators** (100,000+ LUX)
   - Subset of M-Chain validators
   - Specialized hardware (GPU/TEE)
   - Generate proofs

### Hardware Requirements

| Component | Primary | M-Chain | Z-Chain |
|-----------|---------|---------|---------|
| CPU | 8 cores | 16 cores | 32+ cores |
| RAM | 16 GB | 32 GB | 128 GB |
| Storage | 1 TB | 2 TB | 4 TB |
| GPU | Not required | Not required | NVIDIA A100+ |
| TEE | Not required | Optional | Required |

## Use Cases

### 1. Public Cross-Chain Transfer
```typescript
// Using M-Chain for standard bridge
const transfer = await mChain.teleport({
    asset: "USDC",
    amount: "1000",
    from: "ethereum",
    to: "lux-c-chain"
});
```

### 2. Private Cross-Chain Transfer
```typescript
// Using Z-Chain for privacy
const privateTransfer = await zChain.privateTransfer({
    asset: "ETH",
    amount: "10",
    recipient: stealthAddress,
    from: "ethereum",
    to: "lux"
});
```

### 3. AI Model Attestation
```typescript
// Using Z-Chain for TEE attestation
const attestation = await zChain.attestModel({
    modelHash: "0x...",
    teeReport: sgxReport,
    metrics: benchmarks
});
```

### 4. Encrypted Computation
```typescript
// Using Z-Chain FHE
const encryptedVote = await zChain.fhe.encrypt(userVote);
await privateVoting.vote(encryptedVote);
```

## Security Model

### Economic Security
- Validators have significant stake at risk
- Slashing for misbehavior
- Insurance fund from fees

### Cryptographic Security
- **M-Chain**: CGG21 threshold signatures (67/100)
- **Z-Chain**: ZK-SNARKs, FHE, TEE attestations
- **Primary**: Avalanche consensus

### Operational Security
- Key rotation every 30 days
- Hardware security modules
- Distributed infrastructure

## Governance

### On-Chain Governance
- Proposal submission: 10M LUX required
- Voting period: 7 days
- Approval threshold: 75%

### Upgradeable Parameters
- Bridge fees
- Supported assets
- Validator requirements
- Protocol parameters

### Immutable Elements
- Core consensus rules
- Token supply
- Chain IDs

## Implementation Status

| Component | Status | Target |
|-----------|--------|--------|
| Primary Network | ✅ Live | - |
| M-Chain Core | 🚧 Development | Q1 2025 |
| Teleport Protocol | 🚧 Development | Q1 2025 |
| Z-Chain zkEVM | 📋 Planning | Q2 2025 |
| FHE Integration | 📋 Planning | Q3 2025 |
| AI Attestations | 📋 Planning | Q3 2025 |

## Future Enhancements

### Phase 1 (2025 Q1-Q2)
- Launch M-Chain with CGG21 MPC
- Implement Teleport Protocol
- Basic zkEVM on Z-Chain

### Phase 2 (2025 Q3-Q4)
- FHE integration
- Private bridges
- AI attestation framework

### Phase 3 (2026)
- Recursive proofs
- Cross-chain FHE
- Advanced privacy features

## References

- [LIP-001: M-Chain Specification](./LIP-001-M-CHAIN.md)
- [LIP-002: Z-Chain Specification](./LIP-002-Z-CHAIN.md)
- [Lux Network Whitepaper](https://lux.network/whitepaper)
- [CGG21 Paper](https://eprint.iacr.org/2021/060)

## Copyright

Copyright and related rights waived via CC0.