# M-Chain (Money Chain) Migration Plan

## Overview

The B-Chain should be renamed to M-Chain (Money Chain) to better reflect its purpose as the primary cross-chain asset management and settlement layer.

## Architecture Refinement

### Current B-Chain → M-Chain
```
B-Chain (Bridge Chain) → M-Chain (Money Chain)
├── CGG21 MPC Implementation
├── Asset Custody & Settlement
├── X-Chain Integration
├── Teleport Protocol
└── Bridge Governance
```

### Separation of Concerns

#### M-Chain (Money Chain) Responsibilities:
- **Asset Custody**: MPC-based distributed custody
- **Settlement**: X-Chain mint/burn operations
- **Bridge Operations**: Cross-chain asset transfers
- **Governance**: Bridge parameter management
- **Attestation Verification**: Work with A-Chain for hardware attestation

#### Z-Chain (Zero-Knowledge Chain) Responsibilities:
- **Proof Generation**: Create ZK proofs for M-Chain
- **Privacy Operations**: Shielded transfers
- **FHE Computation**: Encrypted operations
- **Verification Services**: Verify proofs for other chains

## Integration Points

### M-Chain ↔ Z-Chain Protocol
```go
// M-Chain requests proof from Z-Chain
type ProofRequest struct {
    RequestID    ids.ID
    ProofType    ProofType
    PublicInputs []byte
    Deadline     time.Time
}

// Z-Chain returns proof
type ProofResponse struct {
    RequestID ids.ID
    Proof     []byte
    ProofType ProofType
    Verified  bool
}
```

### Example Flow: Private Bridge Transfer
1. User initiates transfer on source chain
2. M-Chain locks assets via MPC
3. M-Chain requests ZK proof from Z-Chain
4. Z-Chain generates proof of valid transfer
5. M-Chain mints on X-Chain with proof
6. Settlement completes

## Code Changes Required

### 1. Rename BVM to MVM
```bash
# Rename directories
mv bvm mvm

# Update imports
sed -i 's/bvm/mvm/g' **/*.go

# Update constants
sed -i 's/BVMID/MVMID/g' **/*.go
sed -i 's/BVM/MVM/g' **/*.go
```

### 2. Update VM ID
```go
// Old
BVMID = ids.ID{'b', 'v', 'm'}

// New
MVMID = ids.ID{'m', 'v', 'm'}
```

### 3. Add Z-Chain Client
```go
type ZChainClient interface {
    RequestProof(ctx context.Context, req ProofRequest) (*ProofResponse, error)
    VerifyProof(ctx context.Context, proof []byte) (bool, error)
}
```

### 4. Update Teleport Engine
```go
// Add Z-Chain integration for privacy
func (te *TeleportEngine) ProcessPrivateIntent(ctx context.Context, intent *TeleportIntent) (*TeleportTransfer, error) {
    // Request privacy proof from Z-Chain
    proofReq := ProofRequest{
        ProofType: ProofTypeTransfer,
        PublicInputs: intent.Hash(),
    }
    
    proof, err := te.zchainClient.RequestProof(ctx, proofReq)
    if err != nil {
        return nil, err
    }
    
    // Continue with private transfer
    return te.processWithPrivacy(intent, proof)
}
```

## Benefits of Separation

1. **Clear Purpose**: M for Money, Z for Zero-knowledge
2. **Modularity**: Each chain optimized for its function
3. **Scalability**: Parallel processing of money ops and proofs
4. **Security**: Separation of concerns reduces attack surface
5. **Flexibility**: Can upgrade chains independently

## Migration Timeline

1. **Week 1**: Update codebase with new names
2. **Week 2**: Add Z-Chain client interfaces
3. **Week 3**: Test M-Chain ↔ Z-Chain integration
4. **Week 4**: Deploy to testnet
5. **Week 5-6**: Testing and optimization
6. **Week 7-8**: Mainnet deployment

## Conclusion

Renaming B-Chain to M-Chain and clearly separating money operations from cryptographic proofs creates a cleaner, more scalable architecture. The M-Chain focuses on what it does best - managing money across chains - while the Z-Chain handles all privacy and proof generation needs.