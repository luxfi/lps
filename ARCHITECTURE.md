# Lux Network Architecture

## Overview

The Lux Network consists of multiple specialized chains, each optimized for specific functionality:

```
┌─────────────────────────────────────────────────────────────────┐
│                        Lux Network Architecture                   │
├─────────────────────┬─────────────────────┬────────────────────┤
│    A-Chain          │    M-Chain          │    Z-Chain         │
│  (Attestation)      │    (Money)          │  (Zero-Knowledge)  │
├─────────────────────┼─────────────────────┼────────────────────┤
│ • TEE Attestation   │ • CGG21 MPC         │ • zkEVM/zkVM       │
│ • Hardware RoT      │ • Asset Custody     │ • FHE Operations   │
│ • Validator ID      │ • Bridge Operations │ • ZK Proofs        │
│ • Secure Enclaves   │ • Teleport Protocol │ • Private Contracts│
└─────────────────────┴─────────────────────┴────────────────────┘
                              │
                              ▼
        ┌─────────────────────────────────────────────┐
        │              Primary Network                 │
        ├──────────┬──────────────┬──────────────────┤
        │ P-Chain  │   X-Chain    │    C-Chain       │
        │(Platform)│  (Exchange)  │   (Contract)     │
        └──────────┴──────────────┴──────────────────┘
```

## Chain Responsibilities

### A-Chain (Attestation Chain)
The A-Chain provides hardware-based trust and attestation services:

- **TEE Attestation**: Verifies Trusted Execution Environment attestations
- **Hardware Root of Trust**: Manages hardware security modules
- **Validator Identity**: Cryptographic attestation of validator identities
- **Secure Enclave Management**: Coordinates secure computation environments

### M-Chain (Money Chain)
The M-Chain handles all cross-chain asset operations:

- **CGG21 MPC**: Implements Canetti-Gennaro-Goldfeder 2021 threshold signatures
- **Asset Custody**: Distributed custody using top 100 validators
- **Bridge Operations**: Manages cross-chain asset transfers
- **Teleport Protocol**: Native cross-chain transfers without wrapped assets
- **X-Chain Settlement**: All assets mint/burn on X-Chain for unified settlement

### Z-Chain (Zero-Knowledge Chain)
The Z-Chain provides privacy and cryptographic proof services:

- **zkEVM/zkVM**: Zero-knowledge virtual machines for private computation
- **FHE Operations**: Fully Homomorphic Encryption for computation on encrypted data
- **ZK Proof Generation**: Creates and verifies zero-knowledge proofs
- **Private Smart Contracts**: Confidential contract execution
- **Privacy Preserving Transactions**: Shielded transfers and operations

## Integration Points

### M-Chain ↔ Z-Chain
- M-Chain requests ZK proofs from Z-Chain for cross-chain transfers
- Z-Chain provides privacy proofs for confidential bridge operations
- Shared validator set for security

### A-Chain ↔ M-Chain
- A-Chain attests M-Chain validators for MPC participation
- Hardware-backed key generation and signing

### A-Chain ↔ Z-Chain
- TEE-based ZK proof generation for enhanced security
- Hardware-accelerated FHE operations

## Security Model

1. **Economic Security**: Staked validators secure all chains
2. **Cryptographic Security**: 
   - CGG21 MPC (M-Chain)
   - ZK-SNARKs/STARKs (Z-Chain)
   - TEE Attestation (A-Chain)
3. **Hardware Security**: TEE and HSM integration
4. **Threshold Security**: 2/3+ consensus required

## Implementation Phases

### Phase 1: M-Chain (In Progress)
- Migrate from GG18 to CGG21 MPC
- Implement Teleport Protocol
- X-Chain settlement integration

### Phase 2: Z-Chain
- zkEVM implementation
- FHE integration (Zama.ai style)
- Privacy-preserving bridges

### Phase 3: A-Chain
- TEE attestation framework
- Hardware security module integration
- Validator identity system

## Benefits of This Architecture

1. **Separation of Concerns**: Each chain optimized for its purpose
2. **Scalability**: Parallel processing across specialized chains
3. **Security**: Multiple layers of cryptographic and hardware security
4. **Privacy**: Dedicated privacy chain with state-of-the-art techniques
5. **Interoperability**: Seamless asset movement via Teleport Protocol