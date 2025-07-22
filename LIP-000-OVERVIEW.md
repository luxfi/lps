# LIP-000: Lux Network Architecture Overview

**LIP Number**: 000  
**Title**: Comprehensive Lux Network Architecture  
**Author**: Lux Network Team  
**Status**: Final  
**Type**: Meta  
**Created**: 2025-01-01  
**Updated**: 2025-01-22

## Abstract

This meta-LIP provides a comprehensive overview of the Lux Network architecture, consisting of the Primary Network (P-Chain, X-Chain, C-Chain) and specialized chains (M-Chain for MPC bridge, Z-Chain for privacy).

## Motivation

As the Lux Network evolves to support advanced cross-chain operations, privacy features, and AI/ML workloads, a clear architectural overview helps developers, validators, and users understand how all components work together.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Lux Network Architecture                      │
├─────────────────────────────────────────────────────────────────────┤
│                          Primary Network                              │
├─────────────────────┬─────────────────────┬─────────────────────────┤
│      P-Chain       │      X-Chain         │       C-Chain           │
│    (Platform)      │    (Exchange)        │     (Contract)          │
├─────────────────────┼─────────────────────┼─────────────────────────┤
│ • Validators       │ • UTXO Model         │ • EVM Compatible        │
│ • Subnets          │ • Asset Transfers    │ • Smart Contracts       │
│ • Staking          │ • Settlement Layer   │ • DeFi Ecosystem        │
│ • Governance       │ • High-Perf Exchange │ • OP-Stack Ready        │
└─────────────────────┴─────────────────────┴─────────────────────────┘
                                │
                    ┌───────────┴────────────┐
                    │   Specialized Chains   │
        ┌───────────┴────────┐      ┌────────┴───────────┐
        │     M-Chain         │      │     Z-Chain        │
        │  (Money/MPC Chain)  │      │  (Zero-Knowledge)  │
        ├─────────────────────┤      ├────────────────────┤
        │ • CGG21 MPC         │      │ • zkEVM/zkVM       │
        │ • Asset Bridges     │      │ • FHE Operations   │
        │ • Teleport Protocol │      │ • Privacy Proofs   │
        │ • X-Chain Settlement│      │ • Omnichain Root   │
        │                     │      │ • AI Attestations  │
        └─────────────────────┘      └────────────────────┘

        ┌─────────────────────────────────────────────┐
        │            Bridge SDK (Libraries)           │
        │  Interfaces with M+X+Z chains directly     │
        └─────────────────────────────────────────────┘
```

## Chain Specifications

### Primary Network

#### P-Chain (Platform Chain)
- **Purpose**: Network coordination and governance
- **Features**: Validator management, subnet creation, staking operations
- **Consensus**: Snowman (linear chain)

#### X-Chain (Exchange Chain) - [LIP-006](./LIP-006-X-CHAIN-EXCHANGE.md)
- **Purpose**: High-speed asset transfers, settlement, and on-chain exchange
- **Features**: 
  - UTXO model for fungible assets
  - Native asset creation
  - Universal settlement layer for all chains
  - On-chain CLOB exchange with sub-200ms latency
  - Hyperliquid-style cancel-first ordering
  - GPU-accelerated risk engine (Hanzo)
  - NFT support and transfers
- **Consensus**: Avalanche (DAG) + Snowman++ for exchange

#### C-Chain (Contract Chain)
- **Purpose**: EVM-compatible smart contracts
- **Features**: 
  - Ethereum compatibility (runs geth)
  - OP-Stack ready for L2 scaling
  - DeFi ecosystem
  - NFT support
  - Smart contract platform
- **Consensus**: Snowman with Ethereum block format

### Specialized Chains

#### M-Chain (Money/MPC Chain) - [LIP-004](./LIP-004-M-CHAIN.md)
- **Purpose**: Secure cross-chain asset management
- **Key Features**:
  - CGG21 threshold MPC (67/100 validators)
  - Teleport Protocol for native transfers
  - X-Chain settlement integration
  - Bridge governance
- **Validators**: Top 100 stakers who opt-in

#### Z-Chain (Zero-Knowledge Chain) - [LIP-005](./LIP-005-Z-CHAIN.md)
- **Purpose**: Privacy, cryptographic proofs, and omnichain coordination
- **Key Features**:
  - zkEVM for private smart contracts
  - FHE for encrypted computation
  - zkBridge for private transfers
  - AI/ML model attestations
  - Omnichain cryptographic root (Yggdrasil)
  - Native ZK sequencer
  - Attestation services integrated
- **Validators**: Top validators with specialized hardware (GPU/TEE)

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
- NFT support (including X→C transfers)

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
NFT Transfer: X-Chain → C-Chain (Atomic Swap)
```

**Benefits**:
- Unified liquidity
- Fast finality
- Simple accounting
- Native integration
- Direct NFT bridging

## Validator Architecture

### Validator Tiers

1. **Primary Validators** (2000+ LUX)
   - Validate Primary Network (P, X, C chains)
   - Basic hardware requirements

2. **M-Chain Validators** (1,000,000+ LUX)
   - Top 100 validators by stake
   - Run MPC nodes
   - Share bridge fees

3. **Z-Chain Validators** (100,000+ LUX)
   - Subset of M-Chain validators
   - Specialized hardware (GPU/TEE)
   - Generate ZK proofs
   - Run OP-Stack sequencer

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

### 5. High-Performance Trading
```typescript
// Using X-Chain Exchange
const order = await xChain.exchange.newOrder({
    market: "BTC-PERP",
    side: "buy",
    price: "68000",
    size: "0.2",
    type: "POST_ONLY"
});

// Subscribe to real-time updates
xChain.exchange.bookStream("BTC-PERP", (book) => {
    console.log(`Best bid: ${book.bids[0]}`);
});
```

### 6. NFT Cross-Chain Transfer
```typescript
// Transfer NFT from X-Chain to C-Chain
const transfer = await xChain.nftTransfer({
    collection: "0x...",
    tokenId: 42,
    destination: "c-chain",
    recipient: "0x..."
});
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
| X-Chain Exchange | 📋 Planning | Q2 2025 |
| Z-Chain OP-Stack | 📋 Planning | Q2 2025 |
| Z-Chain zkEVM | 📋 Planning | Q2 2025 |
| FHE Integration | 📋 Planning | Q3 2025 |
| AI Attestations | 📋 Planning | Q3 2025 |

## Future Enhancements

### Phase 1 (2025 Q1-Q2)
- Integrate Teleport Protocol into X-Chain
- Launch X-Chain Exchange alpha
- Deploy Z-Chain with OP-Stack

### Phase 2 (2025 Q3-Q4)
- X-Chain Exchange mainnet (100k TPS)
- Z-Chain zkEVM and FHE
- AI attestation framework

### Phase 3 (2026)
- Recursive proofs and Yggdrasil v2
- Cross-chain FHE computation
- Privacy-preserving exchange features

## References

- [LIP-001: Core Consensus](./LIP-001-CORE-CONSENSUS.md)
- [LIP-002: Tokenomics](./LIP-002-TOKENOMICS.md)
- [LIP-003: C-Chain EVM Standards](./LIP-003-C-CHAIN-EVM.md)
- [LIP-004: M-Chain Specification](./LIP-004-M-CHAIN.md)
- [LIP-005: Z-Chain Specification](./LIP-005-Z-CHAIN.md)
- [LIP-006: X-Chain Exchange Protocol](./LIP-006-X-CHAIN-EXCHANGE.md)
- [LIP-007: OP-Stack Exploration](./LIP-007-OPSTACK-EXPLORATION.md)
- [Lux Network Whitepaper](https://lux.network/whitepaper)
- [CGG21 Paper](https://eprint.iacr.org/2021/060)
- [Hyperliquid L1 Design](https://hyperliquid.xyz/docs)
- [OP-Stack Documentation](https://stack.optimism.io/)

## Copyright

Copyright and related rights waived via CC0.