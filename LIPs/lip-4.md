---
lip: 4
title: Core Consensus and Node Architecture  
description: Defines the core consensus mechanism and node architecture for Lux Network
author: Lux Network Team (@luxdefi)
discussions-to: https://forum.lux.network/lip-4
status: Draft
type: Standards Track
category: Core
created: 2025-01-22
updated: 2025-01-23
---  

## Abstract

This LIP defines the core consensus mechanism and 5-chain architecture of the Lux Network, including the Primary Network (P-Chain, X-Chain, C-Chain) and two specialized chains (M-Chain for MPC bridge, Z-Chain for zero-knowledge operations). It establishes the foundational layer upon which all other network functionality is built.

## Motivation

A clear specification of Lux Network's consensus mechanism and chain architecture provides:
1. **Foundation** for all network operations
2. **Security model** for validators and users
3. **Interoperability** framework between chains
4. **Scalability** path for future growth

## Specification

### 1. Network Architecture

The Lux Network consists of 5 interconnected chains:

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Lux Network Architecture                      │
├─────────────────────────────────────────────────────────────────────┤
│                          Primary Network                              │
├─────────────────────┬─────────────────────┬─────────────────────────┤
│      P-Chain       │      X-Chain         │       C-Chain           │
│    (Platform)      │    (Exchange)        │     (Contract)          │
└─────────────────────┴─────────────────────┴─────────────────────────┘
                                │
                    ┌───────────┴────────────┐
                    │   Specialized Chains   │
        ┌───────────┴────────┐      ┌────────┴───────────┐
        │     M-Chain         │      │     Z-Chain        │
        │  (Money/MPC Chain)  │      │  (Zero-Knowledge)  │
        └─────────────────────┘      └────────────────────┘
```

### 2. Consensus Mechanisms

#### 2.1 Avalanche Consensus Family

Lux Network uses the Avalanche consensus protocol family:

**Snowman** (Linear Chains):
- Used by: P-Chain, C-Chain, M-Chain, Z-Chain
- Properties: Total ordering, optimized for smart contracts
- Finality: ~2 seconds

**Avalanche** (DAG):
- Used by: X-Chain
- Properties: Partial ordering, optimized for high throughput
- Finality: ~1 second

#### 2.2 Consensus Parameters

```go
type ConsensusParams struct {
    // Snow parameters
    K                 uint32 // Sample size (20)
    Alpha             uint32 // Quorum size (15)
    BetaVirtuous      uint32 // Virtuous confidence (15)
    BetaRogue         uint32 // Rogue confidence (20)
    ConcurrentRepolls uint32 // Concurrent repolls (4)
    
    // Timing
    MinBlockTime      time.Duration // 2 seconds
    MaxBlockTime      time.Duration // 3 seconds
    
    // Staking
    MinStakeDuration  time.Duration // 2 weeks
    MaxStakeDuration  time.Duration // 1 year
    MinStakeAmount    uint64        // 2,000 LUX
}
```

### 3. Chain Specifications

#### 3.1 P-Chain (Platform Chain)

**Purpose**: Network coordination, validator management, subnet creation

**State Model**: UTXO-based with accounts for staking

**Key Operations**:
- AddValidator: Stake LUX to become a validator
- AddDelegator: Delegate LUX to a validator
- CreateSubnet: Create a new subnet
- AddSubnetValidator: Validate a subnet

**Staking Requirements**:
```go
const (
    MinValidatorStake = 2_000 * units.Lux     // 2,000 LUX
    MinDelegatorStake = 25 * units.Lux        // 25 LUX
    MaxStakeMultiplier = 5                     // Max 5x delegation per validator
)
```

#### 3.2 X-Chain (Exchange Chain)

**Purpose**: Digital asset creation and exchange

**State Model**: UTXO-based

**Key Features**:
- Native asset creation
- Atomic swaps
- Settlement layer for all chains
- Future: High-performance exchange (see LIP-006)

**Transaction Types**:
- BaseTx: Simple asset transfer
- CreateAssetTx: Create new asset
- OperationTx: Complex operations
- ImportTx/ExportTx: Cross-chain transfers

#### 3.3 C-Chain (Contract Chain)

**Purpose**: EVM-compatible smart contracts

**State Model**: Account-based (Ethereum-compatible)

**Key Features**:
- Full EVM compatibility
- Runs modified geth (coreth)
- DeFi ecosystem support
- Future: OP-Stack L2 support (see LIP-007)

**Consensus Wrapper**:
```go
// Wraps Ethereum block format with Snowman consensus
type Block struct {
    ethBlock *types.Block
    vm       *VM
}
```

#### 3.4 M-Chain (Money/MPC Chain)

**Purpose**: Secure cross-chain bridge using MPC

**State Model**: Account-based with threshold signatures

**Key Features**:
- CGG21 threshold MPC (67/100 validators)
- Teleport Protocol for native transfers
- X-Chain settlement integration

**Detailed specification**: See LIP-004

#### 3.5 Z-Chain (Zero-Knowledge Chain)

**Purpose**: Privacy and cryptographic proofs

**State Model**: Hybrid (shielded pool + account model)

**Key Features**:
- zkEVM for private smart contracts
- FHE for encrypted computation
- Omnichain root (Yggdrasil)
- AI/ML attestations

**Detailed specification**: See LIP-005

### 4. Validator Architecture

#### 4.1 Validator Types

**Primary Network Validators**:
- Stake: 2,000+ LUX
- Validate: P, X, C chains
- Rewards: Block rewards + fees

**M-Chain Validators** (Top 100):
- Additional requirement: Top 100 by stake
- Run MPC key shares
- Additional rewards: Bridge fees

**Z-Chain Validators**:
- Additional requirement: 100,000+ LUX stake
- Specialized hardware (GPU, TEE)
- Additional rewards: ZK proof fees

#### 4.2 Validator Selection

```go
func SelectValidators(chain ChainID, height uint64) []Validator {
    allValidators := GetActiveValidators(height)
    
    switch chain {
    case PChainID, XChainID, CChainID:
        return allValidators // All validators validate primary network
        
    case MChainID:
        // Top 100 by stake who opted in
        sorted := SortByStake(allValidators)
        return FilterOptedIn(sorted[:100], MChainID)
        
    case ZChainID:
        // Subset with specialized hardware
        return FilterByCapability(allValidators, ZKHardware)
    }
}
```

### 5. Cross-Chain Communication

#### 5.1 Atomic Swaps

Chains communicate via atomic operations:

```go
// Export from source chain
exportTx := &ExportTx{
    BaseTx: BaseTx{...},
    DestinationChain: destChainID,
    ExportedOutputs: outputs,
}

// Import to destination chain
importTx := &ImportTx{
    BaseTx: BaseTx{...},
    SourceChain: sourceChainID,
    ImportedInputs: inputs,
}
```

#### 5.2 Warp Messaging

Fast cross-chain messaging for specialized operations:

```go
type WarpMessage struct {
    SourceChainID      ids.ID
    DestinationChainID ids.ID
    Payload            []byte
    Signature          *Signature // BLS aggregate
}
```

### 6. Security Model

#### 6.1 Safety Threshold

The network remains safe as long as:
- **Primary Network**: >80% of stake is honest
- **M-Chain**: >66% of top 100 validators are honest
- **Z-Chain**: Cryptographic assumptions hold

#### 6.2 Liveness Threshold

The network remains live as long as:
- **Primary Network**: >67% of stake is online
- **M-Chain**: >67 of top 100 validators are online
- **Z-Chain**: >50% of ZK validators are online

### 7. Performance Characteristics

| Metric | P-Chain | X-Chain | C-Chain | M-Chain | Z-Chain |
|--------|---------|---------|---------|---------|---------|
| TPS | 1,000 | 4,500 | 1,000 | 10,000 | 500 |
| Finality | 2s | 1s | 2s | 2s | 3s |
| Block Time | 2s | N/A | 2s | 2s | 3s |

### 8. Network Parameters

```go
const (
    // Network IDs
    MainnetID uint32 = 1
    TestnetID uint32 = 5
    
    // Chain IDs
    PChainID = ids.ID{0x00, 0x00, 0x00, 0x00, 0x00, ...}
    XChainID = ids.ID{0x01, 0x00, 0x00, 0x00, 0x00, ...}
    CChainID = ids.ID{0x02, 0x00, 0x00, 0x00, 0x00, ...}
    MChainID = ids.ID{0x03, 0x00, 0x00, 0x00, 0x00, ...}
    ZChainID = ids.ID{0x04, 0x00, 0x00, 0x00, 0x00, ...}
)
```

## Rationale

This 5-chain architecture provides:

1. **Separation of Concerns**: Each chain optimized for its purpose
2. **Scalability**: Parallel processing across chains
3. **Security**: Isolated failure domains
4. **Flexibility**: New chains can be added as subnets

The Avalanche consensus family provides:
1. **Fast finality**: Sub-3 second finality
2. **High throughput**: Thousands of TPS
3. **Energy efficiency**: No mining required
4. **Scalability**: Performance improves with more validators

## Implementation

Reference implementation: `github.com/luxfi/node`

Key components:
- `snow/`: Consensus implementation
- `vms/platformvm/`: P-Chain VM
- `vms/xvm/`: X-Chain VM  
- `vms/evm/`: C-Chain VM (coreth)
- `vms/mvm/`: M-Chain VM (future)
- `vms/zvm/`: Z-Chain VM (future)

## Security Considerations

1. **Validator Collusion**: Threshold signatures prevent minority attacks
2. **Cross-chain Replay**: Each chain has unique ID preventing replay
3. **Time-based Attacks**: Chains maintain independent time
4. **State Explosion**: State pruning and fees prevent bloat

## Copyright

Copyright and related rights waived via CC0.