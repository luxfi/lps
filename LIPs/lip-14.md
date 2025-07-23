---
lip: 14
title: Z-Chain (Zero-Knowledge Chain) Specification
description: Defines the Zero-Knowledge chain for privacy and cryptographic proofs
author: Lux Network Team (@luxdefi)
discussions-to: https://forum.lux.network/lip-14
status: Draft
type: Standards Track
category: Core
created: 2025-01-22
updated: 2025-01-23
requires: 0, 4, 11, 13
---

## Abstract

This LIP specifies the Z-Chain (Zero-Knowledge Chain), a specialized blockchain within the Lux Network that provides privacy-preserving transactions, zero-knowledge proof generation, fully homomorphic encryption (FHE), and trusted execution attestations. The Z-Chain enables private cross-chain transfers via zkBridge, supports AI/ML workload attestations, and maintains the omnichain cryptographic root (Yggdrasil).

## Motivation

As blockchain adoption grows, privacy and verifiable computation become critical:

1. **Privacy**: Users need confidential transactions without sacrificing compliance
2. **Verifiable Computation**: AI/ML models require attestation of integrity
3. **Cross-chain Privacy**: Private bridges preserve confidentiality across chains
4. **Regulatory Compliance**: Selective disclosure for regulatory requirements

## Specification

### 1. Architecture Overview

```
Z-Chain Architecture
├── zkEVM Layer (Privacy-preserving EVM)
├── FHE Engine (Encrypted Computation)
├── Proof Systems (Groth16, PLONK, STARKs)
├── Attestation Service (TEE/SGX)
├── zkBridge (Private Cross-chain)
├── Yggdrasil Root (Omnichain State)
├── ZK Sequencer (Native)
└── Compliance Module (Selective Disclosure)
```

### 2. Core Components

#### 2.1 ZK Sequencer

Native zero-knowledge sequencer optimized for privacy operations:

```rust
pub struct ZKSequencer {
    // Core components
    mempool: PrivateMempool,
    block_producer: BlockProducer,
    proof_generator: ProofGenerator,
    
    // State management
    state_tree: SparseMerkleTree,
    nullifier_tree: MerkleTree<Nullifier>,
    yggdrasil: OmnichainRoot,
    
    // Consensus
    validators: ValidatorSet,
    consensus: SnowmanConsensus,
}

impl ZKSequencer {
    fn produce_block(&self, private_txs: Vec<PrivateTx>) -> ZKBlock {
        // Sort by fee and priority
        let sorted_txs = self.mempool.get_sorted_txs();
        
        // Generate block with proofs
        let block = self.block_producer.create_block(sorted_txs);
        let proof = self.proof_generator.prove_block(&block);
        
        // Update omnichain root
        self.yggdrasil.update(block.state_root());
        
        ZKBlock {
            header: block.header,
            body: block.body,
            proof,
            yggdrasil_root: self.yggdrasil.root(),
        }
    }
}
```

#### 2.2 zkEVM Implementation

Privacy-preserving smart contract execution:

```rust
pub struct ZkEVM {
    // State management
    private_state: EncryptedStateDB,
    nullifier_tree: MerkleTree<Nullifier>,
    note_tree: MerkleTree<Note>,
    
    // Proof generation
    proving_key: ProvingKey,
    verifying_key: VerifyingKey,
    
    // Execution engine
    vm: EVM<PrivateContext>,
}

pub struct PrivateTransaction {
    nullifiers: Vec<Nullifier>,
    commitments: Vec<Commitment>,
    encrypted_data: Vec<u8>,
    proof: Proof,
}
```

**Key Features**:
- Shielded transfers using UTXO model
- Private smart contract execution
- Nullifier-based double-spend prevention

#### 2.2 FHE Integration

Computation on encrypted data:

```rust
pub struct FHEEngine {
    // FHE parameters
    params: FHEParameters,
    public_key: FHEPublicKey,
    evaluation_key: FHEEvaluationKey,
    
    // Operations
    add: fn(Ciphertext, Ciphertext) -> Ciphertext,
    multiply: fn(Ciphertext, Ciphertext) -> Ciphertext,
    bootstrap: fn(Ciphertext) -> Ciphertext,
}

// Example: Private voting
pub fn encrypted_vote(
    encrypted_choice: Ciphertext,
    tally: &mut EncryptedTally
) -> Result<()> {
    tally.yes = fhe.add(tally.yes, fhe.select(encrypted_choice, 1, 0));
    tally.no = fhe.add(tally.no, fhe.select(encrypted_choice, 0, 1));
    Ok(())
}
```

**Supported Operations**:
- Arithmetic: +, -, ×
- Boolean: AND, OR, NOT, XOR
- Comparison: >, <, =
- Bootstrapping for unlimited depth

#### 2.3 Proof Systems

Multiple proof systems for different use cases:

```rust
pub enum ProofSystem {
    Groth16 {       // Efficient, requires trusted setup
        crs: CommonReferenceString,
    },
    PLONK {         // Universal trusted setup
        srs: StructuredReferenceString,
    },
    STARK {         // Post-quantum, no setup
        fri_params: FRIParameters,
    },
    Bulletproofs {  // Range proofs
        generators: Generators,
    },
}

pub trait Prover {
    fn prove(&self, witness: Witness, public: PublicInputs) -> Proof;
    fn verify(&self, proof: Proof, public: PublicInputs) -> bool;
}
```

#### 2.4 zkBridge Protocol

Private cross-chain transfers:

```rust
pub struct ZKBridge {
    // Bridge state
    deposits: HashMap<ChainId, MerkleTree<Deposit>>,
    withdrawals: HashMap<ChainId, Vec<Nullifier>>,
    
    // Integration
    m_chain_client: MChainClient,
    proof_generator: ProofGenerator,
}

pub struct PrivateTransfer {
    source_chain: ChainId,
    dest_chain: ChainId,
    nullifier: Nullifier,
    commitment: Commitment,
    encrypted_amount: Ciphertext,
    proof: TransferProof,
}
```

**Transfer Flow**:
1. Deposit assets on source chain
2. Generate commitment and nullifier
3. Create ZK proof of valid transfer
4. Submit proof to Z-Chain
5. M-Chain executes based on proof

#### 2.5 AI/ML Attestation Service

Trusted execution verification:

```rust
pub struct AttestationService {
    // TEE verification
    sgx_verifier: SGXVerifier,
    sev_verifier: SEVVerifier,
    
    // Model registry
    attested_models: HashMap<ModelHash, Attestation>,
}

pub struct ModelAttestation {
    model_hash: Hash,
    tee_report: TEEReport,
    performance_metrics: Metrics,
    timestamp: u64,
    validator_signatures: Vec<Signature>,
}
```

### 3. Privacy Features

#### 3.1 Shielded Accounts

```rust
pub struct ShieldedAccount {
    // Viewing keys for selective disclosure
    viewing_key: ViewingKey,
    spending_key: SpendingKey,
    
    // Derived addresses
    diversified_addresses: Vec<DiversifiedAddress>,
}
```

#### 3.2 Privacy Pools

Tornado Cash-style mixing with compliance:

```rust
pub struct PrivacyPool {
    denomination: u128,
    merkle_tree: MerkleTree<Commitment>,
    nullifiers: HashSet<Nullifier>,
    compliance_hook: Option<ComplianceCheck>,
}
```

#### 3.3 Selective Disclosure

For regulatory compliance:

```rust
pub struct ViewingCredential {
    scope: ViewingScope,
    expiry: Timestamp,
    signature: Signature,
}

pub enum ViewingScope {
    Transaction(TxId),
    Account(AccountId),
    TimeRange(Start, End),
}
```

### 4. Integration with M-Chain

#### 4.1 Proof Requests

```rust
// M-Chain requests proof from Z-Chain
pub struct ProofRequest {
    request_id: RequestId,
    proof_type: ProofType,
    public_inputs: Vec<u8>,
    deadline: Timestamp,
}

// Z-Chain response
pub struct ProofResponse {
    request_id: RequestId,
    proof: Proof,
    verification_key: VerifyingKey,
}
```

#### 4.2 Private Settlement

```rust
// Private transfer via M-Chain
async fn private_cross_chain_transfer(
    amount: u128,
    recipient: StealthAddress,
    source_chain: ChainId,
    dest_chain: ChainId,
) -> Result<TransferId> {
    // Generate private transfer proof
    let proof = z_chain.generate_transfer_proof(
        amount,
        recipient,
        source_chain,
        dest_chain,
    ).await?;
    
    // M-Chain executes based on proof
    m_chain.execute_private_transfer(proof).await
}
```

### 5. Yggdrasil - Omnichain Cryptographic Root

The Yggdrasil system maintains a unified cryptographic root across all chains:

```rust
pub struct Yggdrasil {
    // Chain roots
    roots: HashMap<ChainId, StateRoot>,
    
    // Merkle tree of all chain states
    omni_tree: MerkleTree<ChainState>,
    
    // Attestations from validators
    attestations: Vec<Attestation>,
}

impl Yggdrasil {
    pub fn update_chain_state(&mut self, chain: ChainId, root: StateRoot) {
        self.roots.insert(chain, root);
        self.recompute_omni_root();
    }
    
    pub fn generate_inclusion_proof(
        &self, 
        chain: ChainId, 
        element: Hash
    ) -> InclusionProof {
        // Generate proof that element exists in chain's state
        // and chain's state is included in omnichain root
    }
}
```

**Benefits**:
- Single source of truth for cross-chain state
- Efficient cross-chain verification
- Enables atomic cross-chain operations
- Foundation for cross-chain composability

### 6. Validator Requirements

#### 6.1 Hardware Requirements
- CPU: 32+ cores (AMD EPYC or Intel Xeon)
- RAM: 128GB minimum
- GPU: NVIDIA A100 or H100 (for proof generation)
- Storage: 4TB NVMe SSD
- TEE: Intel SGX or AMD SEV (for attestations)

#### 5.2 Staking
- Minimum stake: 100,000 LUX
- Must also validate M-Chain
- Additional hardware requirements

### 6. API Specification

```typescript
interface ZChainAPI {
    // Privacy operations
    shieldAssets(amount: BigNumber, asset: Asset): Promise<ShieldedNote>
    privateTransfer(note: ShieldedNote, recipient: StealthAddress): Promise<TxHash>
    
    // Proof generation
    generateProof(circuit: Circuit, witness: Witness): Promise<Proof>
    verifyProof(proof: Proof, publicInputs: any[]): Promise<boolean>
    
    // FHE operations
    encrypt(value: BigNumber, publicKey: FHEPublicKey): Promise<Ciphertext>
    computeOnEncrypted(operation: FHEOp, ...inputs: Ciphertext[]): Promise<Ciphertext>
    
    // Attestations
    attestModel(modelHash: Hash, teeReport: Report): Promise<Attestation>
    verifyAttestation(attestation: Attestation): Promise<boolean>
}
```

### 7. Performance Targets

- **Proof Generation**: < 10 seconds for typical transfers
- **FHE Operations**: 1000 ops/second
- **Throughput**: 100 private transactions/second
- **Finality**: 2-3 seconds

### 8. Security Model

#### 8.1 Cryptographic Assumptions
- Discrete log problem (Groth16, PLONK)
- Hash function collision resistance (STARKs)
- Ring-LWE hardness (FHE)

#### 8.2 Privacy Guarantees
- Perfect zero-knowledge for transfers
- Semantic security for FHE
- Forward secrecy for viewing keys

## Rationale

The Z-Chain design balances:

1. **Privacy**: Strong privacy guarantees with compliance hooks
2. **Performance**: Hardware acceleration and optimized circuits
3. **Flexibility**: Multiple proof systems for different use cases
4. **Integration**: Seamless interaction with M-Chain

## Backwards Compatibility

The Z-Chain is a new addition and maintains compatibility through:
- Standard Ethereum JSON-RPC for zkEVM
- Existing bridge interfaces via M-Chain

## Test Cases

1. **Private Transfer**: Shield 100 LUX, transfer privately, unshield
2. **FHE Computation**: Encrypted voting with 1000 participants
3. **Cross-chain Privacy**: Private transfer ETH → LUX
4. **AI Attestation**: Attest GPT model execution in SGX

## Implementation

Reference implementation: `github.com/luxfi/z-chain`

Key components:
- `zkvm/`: Zero-knowledge virtual machine
- `fhe/`: FHE engine based on TFHE-rs
- `attestation/`: TEE verification service
- `bridge/`: zkBridge implementation

## Security Considerations

1. **Trusted Setup**: Use Powers of Tau ceremony for Groth16
2. **Side Channels**: Constant-time implementations required
3. **Key Management**: Hardware security modules for keys
4. **Quantum Security**: Migration path to post-quantum proofs

## Economic Model

### Fee Structure
- Base fee: 0.1 LUX per private transaction
- Proof generation: Variable based on complexity
- FHE operations: 0.001 LUX per operation

### Validator Rewards
- 50% of fees to proof generators
- 30% to validators
- 20% to treasury

## Future Enhancements

1. **Recursive Proofs**: Aggregate multiple proofs
2. **Cross-chain FHE**: Encrypted state across chains
3. **Decentralized Attestation**: Multiple TEE providers
4. **Privacy DEX**: Fully private order matching

## Copyright

Copyright and related rights waived via CC0.