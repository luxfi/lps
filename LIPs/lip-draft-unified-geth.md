---
lip: draft
title: Unified Geth - Multi-Mode EVM Execution Layer
description: A unified EVM implementation supporting multiple execution modes for the Lux ecosystem
author: Lux Core Team
discussions-to: https://github.com/luxfi/lips/discussions/draft-unified-geth
status: Draft
type: Standards Track
category: Core
created: 2025-07-22
requires: 
---

## Abstract

This LIP proposes unifying all EVM implementations in the Lux ecosystem into a single, mode-configurable `geth` package. This eliminates code duplication, import cycles, and maintenance overhead while providing a flexible execution layer that can operate as a C-Chain node (like coreth), L2 subnet, OP Stack rollup, or sovereign L1.

## Motivation

Currently, the Lux ecosystem maintains multiple overlapping EVM implementations:
- `evm` package (derived from subnet-evm)
- `geth` wrapper around go-ethereum
- Import cycles between packages
- Duplicated functionality across implementations

This fragmentation creates:
- Maintenance burden keeping multiple codebases in sync
- Import cycle issues preventing clean builds
- Confusion about which implementation to use
- Difficulty adding new features across all modes

## Specification

### Architecture Overview

The unified geth package will be structured as:

```
geth/
├── core/                    # Core blockchain logic from go-ethereum
│   ├── vm/                  # EVM with mode-aware execution
│   ├── state/              # Unified state management
│   └── types/              # Transaction types for all modes
├── consensus/              # Pluggable consensus engines
│   ├── lux/                # Lux avalanche consensus
│   ├── sequencer/          # Rollup sequencer consensus
│   └── sovereign/          # Custom L1 consensus
├── mode/                   # Mode-specific implementations
│   ├── cchain/             # C-Chain compatibility
│   ├── subnet/             # L2 subnet features
│   ├── rollup/             # Rollup modes (OP, Arbitrum, etc.)
│   └── sovereign/          # Sovereign L1 chains
├── precompile/             # Unified precompile registry
│   ├── contracts/          # All precompiled contracts
│   └── registry.go         # Dynamic loading by mode
└── plugin/                 # VM plugin for Lux node
    └── evm/                # Plugin implementation
```

### Mode Configuration

```go
type ExecutionMode string

const (
    // C-Chain mode - primary network compatibility
    ModeCChain ExecutionMode = "c-chain"
    
    // Subnet L2 mode - Lux subnets with configurable tokens
    ModeSubnetL2 ExecutionMode = "subnet-l2"
    
    // Rollup modes - L2s posting to L1
    ModeOPStack ExecutionMode = "op-stack"
    ModeArbitrum ExecutionMode = "arbitrum"
    ModeZKSync ExecutionMode = "zksync"
    
    // Sovereign L1 mode - independent chains
    ModeSovereign ExecutionMode = "sovereign"
)

type UnifiedConfig struct {
    // Execution mode selection
    Mode ExecutionMode `json:"mode"`
    
    // Genesis configuration
    GenesisFile string `json:"genesisFile,omitempty"`
    GenesisHash string `json:"genesisHash,omitempty"`
    
    // Mode-specific configurations
    CChain    *CChainConfig    `json:"cchain,omitempty"`
    Subnet    *SubnetConfig    `json:"subnet,omitempty"`
    Rollup    *RollupConfig    `json:"rollup,omitempty"`
    Sovereign *SovereignConfig `json:"sovereign,omitempty"`
    
    // Common chain configuration
    ChainConfig *params.ChainConfig `json:"chainConfig"`
}
```

### Mode-Specific Features

#### C-Chain Mode
- Full compatibility with existing C-Chain state
- LUX as native token
- Avalanche consensus integration
- Cross-chain messaging via Warp
- Import existing validator set

#### Subnet L2 Mode
- Configurable native token
- Elastic subnet support
- Cross-subnet transfers
- State sync from parent chain
- Custom precompiles:
  - Contract deployer allowlist
  - Transaction allowlist  
  - Native minter
  - Fee configuration

#### Rollup Modes
- OP Stack:
  - Optimistic fraud proofs
  - L1 data availability
  - Canonical bridge
- Arbitrum:
  - Interactive fraud proofs
  - Compressed calldata
  - Delayed inbox
- zkSync:
  - ZK validity proofs
  - Account abstraction
  - Native paymasters

#### Sovereign L1 Mode
- Independent validator set
- Custom consensus rules
- Optional IBC connections
- Bridge adapters
- Custom tokenomics

### Precompile Registry

Dynamic precompile loading based on execution mode:

```go
type PrecompileRegistry struct {
    // Base precompiles available in all modes
    base map[common.Address]contract.StatefulPrecompiledContract
    
    // Mode-specific precompiles
    modeSpecific map[ExecutionMode]map[common.Address]contract.StatefulPrecompiledContract
}

func (r *PrecompileRegistry) GetActivePrecompiles(mode ExecutionMode, blockTime uint64) map[common.Address]contract.StatefulPrecompiledContract {
    active := make(map[common.Address]contract.StatefulPrecompiledContract)
    
    // Add base precompiles
    for addr, pc := range r.base {
        active[addr] = pc
    }
    
    // Add mode-specific precompiles
    if modePrecompiles, ok := r.modeSpecific[mode]; ok {
        for addr, pc := range modePrecompiles {
            active[addr] = pc
        }
    }
    
    return active
}
```

### State Compatibility

The unified geth will support loading existing chain states:

```go
type StateLoader interface {
    // Load existing C-Chain state
    LoadCChainState(stateRoot common.Hash) (*state.StateDB, error)
    
    // Load subnet state with migration
    LoadSubnetState(subnetID ids.ID, stateRoot common.Hash) (*state.StateDB, error)
    
    // Import from external chain
    ImportExternalState(format string, data []byte) (*state.StateDB, error)
}
```

## Implementation Plan

### Phase 1: Base Structure (Week 1-2)
1. Fork latest go-ethereum into geth package
2. Add mode configuration system
3. Create plugin interface for Lux node
4. Set up build system for all modes

### Phase 2: C-Chain Mode (Week 3-4)
1. Port Avalanche consensus integration from coreth
2. Implement C-Chain specific precompiles
3. Add Warp messaging support
4. Test C-Chain state compatibility

### Phase 3: Subnet Mode (Week 5-6)
1. Port subnet-evm features
2. Implement elastic subnet support
3. Add configurable precompiles
4. Test with existing subnets

### Phase 4: Rollup Modes (Week 7-8)
1. Implement OP Stack support
2. Add Arbitrum compatibility
3. Create rollup utilities
4. Test with testnets

### Phase 5: Migration Tools (Week 9-10)
1. State migration utilities
2. Configuration converters
3. Deployment scripts
4. Documentation

## Backwards Compatibility

The unified geth maintains compatibility through:
- Mode selection preserving existing behavior
- State migration tools for existing chains
- Compatible RPC interfaces
- Plugin API compatibility with Lux node

## Test Cases

1. **C-Chain Compatibility**
   - Deploy unified geth in C-Chain mode
   - Sync with existing C-Chain
   - Verify state roots match
   - Test transaction processing

2. **Subnet Migration**
   - Create new subnet with unified geth
   - Migrate existing subnet-evm chain
   - Verify state consistency
   - Test cross-subnet transfers

3. **Rollup Deployment**
   - Deploy OP Stack rollup
   - Post batches to L1
   - Verify fraud proof challenges
   - Test canonical bridge

4. **Mode Switching**
   - Start chain in one mode
   - Export state
   - Import into different mode
   - Verify functionality

## Security Considerations

1. **Mode Isolation**: Ensure mode-specific code cannot affect other modes
2. **Precompile Security**: Validate all precompiles for each mode
3. **State Migration**: Verify state integrity during migrations
4. **Consensus Safety**: Each mode must maintain consensus guarantees

## Economic Considerations

1. **Gas Compatibility**: Maintain gas costs across modes where applicable
2. **Token Standards**: Support different native tokens per mode
3. **Fee Markets**: Mode-appropriate fee mechanisms (EIP-1559, priority fees, etc.)

## References

- [Go-Ethereum](https://github.com/ethereum/go-ethereum)
- [Coreth](https://github.com/ava-labs/coreth)
- [Subnet-EVM](https://github.com/ava-labs/subnet-evm)
- [OP Stack](https://docs.optimism.io/)
- [Arbitrum Nitro](https://github.com/OffchainLabs/nitro)

## Copyright

Copyright and related rights waived via CC0.