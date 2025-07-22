# LIP-004: M-Chain (Money Chain) Specification

**LIP Number**: 004  
**Title**: M-Chain - Threshold MPC Cross-Chain Asset Management  
**Author**: Lux Network Team  
**Status**: Draft  
**Type**: Standards Track  
**Created**: 2025-01-22  

## Abstract

This LIP specifies the M-Chain (Money Chain), a specialized blockchain within the Lux Network that provides secure cross-chain asset management using threshold Multi-Party Computation (MPC). The M-Chain implements the CGG21 protocol for distributed custody and introduces the Teleport Protocol for native cross-chain asset transfers.

## Motivation

Current blockchain bridges rely on centralized custodians or simple multisig wallets, creating single points of failure. The M-Chain addresses these limitations by:

1. Implementing threshold MPC for truly distributed custody
2. Using X-Chain as a universal settlement layer
3. Enabling native asset transfers without wrapped tokens
4. Providing cryptographic security with economic incentives

## Specification

### 1. Architecture Overview

```
M-Chain Architecture
├── Consensus Layer (Linear VM)
├── MPC Layer (CGG21 Protocol)
├── Settlement Layer (X-Chain Integration)
├── Teleport Protocol Engine
└── Governance Module
```

### 2. Core Components

#### 2.1 CGG21 MPC Implementation

The M-Chain uses the Canetti-Gennaro-Goldfeder 2021 (CGG21) threshold signature scheme:

```go
type MPCManager struct {
    threshold      uint32  // 2/3 + 1 of validators
    partyCount     uint32  // Top 100 validators
    keyShares      map[ids.ID]*KeyShare
    sessionManager *SessionManager
}

type KeyShare struct {
    KeyID        ids.ID
    PartyID      ids.NodeID
    Share        []byte
    PublicKey    *ecdsa.PublicKey
    Threshold    uint32
}
```

**Key Generation Process**:
1. Distributed key generation among top 100 validators
2. Each validator holds a key share
3. Threshold of 67 validators required for signing

#### 2.2 Teleport Protocol

The Teleport Protocol enables native cross-chain transfers:

```go
type TeleportIntent struct {
    ID          ids.ID
    Type        IntentType
    SourceAsset AssetIdentifier
    DestAsset   AssetIdentifier
    Amount      *big.Int
    Sender      common.Address
    Recipient   common.Address
    Deadline    time.Time
}

type TeleportEngine struct {
    intentPool       *IntentPool
    executorEngine   *ExecutorEngine
    xchainSettlement *XChainSettlement
    mpcManager       *MPCManager
}
```

**Transfer Flow**:
1. User signs intent to transfer assets
2. M-Chain validators lock assets on source chain
3. X-Chain mints/burns for settlement
4. Assets released on destination chain

#### 2.3 X-Chain Settlement

All cross-chain transfers settle through X-Chain:

```go
type XChainSettlement struct {
    client       *XChainClient
    mpcWallet    *MPCWallet
    
    ProcessIncomingAssets()  // Mint on X-Chain
    ProcessOutgoingAssets()  // Burn on X-Chain
}
```

### 3. Validator Requirements

#### 3.1 Eligibility
- Must be in top 100 validators by stake
- Minimum stake: 1,000,000 LUX
- Must opt-in to M-Chain validation

#### 3.2 Responsibilities
- Participate in MPC key generation
- Sign valid cross-chain transactions
- Maintain uptime > 98%

#### 3.3 Rewards
- Share of bridge fees (0.3% of transfer volume)
- Additional LUX rewards from protocol

### 4. Security Model

#### 4.1 Cryptographic Security
- CGG21 threshold signatures (67/100 required)
- Regular key rotation every 30 days
- Proactive secret sharing for key refresh

#### 4.2 Economic Security
- Validators have significant stake at risk
- Slashing for misbehavior
- Insurance fund from fees

### 5. Asset Types Supported

#### 5.1 Fungible Tokens
- ERC-20 compatible tokens
- Native chain assets (ETH, BNB, etc.)
- Stablecoins with special handling

#### 5.2 Non-Fungible Tokens (NFTs)
- ERC-721 NFTs
- ERC-1155 multi-tokens
- Special "Validator NFTs" for P-Chain staking

### 6. Integration Points

#### 6.1 With Primary Network
- P-Chain: Validator management
- X-Chain: Settlement layer
- C-Chain: Smart contract interactions

#### 6.2 With Z-Chain
- Request ZK proofs for private transfers
- Verify attestations for compliance

### 7. API Specification

```typescript
interface MChainAPI {
    // Asset transfers
    initiateTransfer(intent: TeleportIntent): Promise<TransferID>
    getTransferStatus(id: TransferID): Promise<TransferStatus>
    
    // MPC operations
    getMPCPublicKey(): Promise<PublicKey>
    getValidatorSet(): Promise<ValidatorInfo[]>
    
    // Bridge info
    getSupportedAssets(): Promise<Asset[]>
    getBridgeFees(asset: Asset, amount: BigNumber): Promise<Fee>
}
```

### 8. Governance

#### 8.1 Parameters
- Bridge fees: 0.3% (adjustable by governance)
- Validator threshold: 67/100 (requires hard fork to change)
- Supported assets: Added by governance vote

#### 8.2 Upgrade Process
- Proposals require 10M LUX backing
- 7-day voting period
- 75% approval threshold

## Rationale

The M-Chain design prioritizes:

1. **Security**: Threshold MPC eliminates single points of failure
2. **Efficiency**: X-Chain settlement provides fast finality
3. **Simplicity**: Clear separation from privacy (Z-Chain) concerns
4. **Scalability**: Can process thousands of transfers per second

## Backwards Compatibility

The M-Chain is a new addition and does not break existing functionality. It will replace the current GG18-based bridge with superior CGG21 security.

## Test Cases

1. **Key Generation**: Test distributed key generation with 100 parties
2. **Threshold Signing**: Verify 67/100 threshold enforcement
3. **Asset Transfer**: Test transfers of various asset types
4. **Failure Recovery**: Test system resilience to validator failures

## Implementation

The reference implementation is available at: `github.com/luxfi/node/bvm`

Key files:
- `mpc_manager.go`: CGG21 implementation
- `teleport_engine.go`: Teleport Protocol
- `xchain_settlement.go`: X-Chain integration

## Security Considerations

1. **Key Compromise**: Even if 33 validators are compromised, funds remain safe
2. **Censorship**: 34+ honest validators can always process transfers
3. **Front-running**: Intents include deadlines and slippage protection
4. **Quantum Security**: Plan to migrate to post-quantum signatures

## Copyright

Copyright and related rights waived via CC0.