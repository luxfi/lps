---
lip: 0
title: Lux Network Architecture & Community Framework
description: Comprehensive overview of Lux Network architecture and framework for community contributions
author: Lux Network Team (@luxdefi)
discussions-to: https://forum.lux.network/lip-0
status: Final
type: Meta
created: 2025-01-01
updated: 2025-01-23
---

## Abstract

This meta-LIP provides a comprehensive overview of the Lux Network architecture and establishes the framework for community contributions to the ecosystem. It serves as the foundational document that describes the network's multi-chain architecture (Primary Network and specialized chains), core protocols, and guidelines for community participation in the development and improvement of Lux Network.

## Motivation

As the Lux Network evolves to support advanced cross-chain operations, privacy features, and a growing ecosystem of applications, we need:

1. **Clear Architecture Documentation**: A comprehensive reference for developers, validators, and users to understand how all components work together
2. **Community Contribution Framework**: Structured processes to leverage open-source collaboration for accelerating growth and innovation
3. **Unified Vision**: A single source of truth for the network's design principles and future direction

## Part 1: Network Architecture

### Architecture Overview

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
```

### Chain Specifications

#### Primary Network

**P-Chain (Platform Chain)**
- Purpose: Network coordination and governance
- Features: Validator management, subnet creation, staking operations
- Consensus: Snowman (linear chain)
- See: LIP-10 for detailed specification

**X-Chain (Exchange Chain)**
- Purpose: High-speed asset transfers, settlement, and on-chain exchange
- Features: UTXO model, native asset creation, universal settlement layer, on-chain CLOB exchange
- Consensus: Avalanche (DAG) + Snowman++ for exchange
- See: LIP-11 for detailed specification

**C-Chain (Contract Chain)**
- Purpose: EVM-compatible smart contracts
- Features: Ethereum compatibility, OP-Stack ready, DeFi ecosystem, NFT support
- Consensus: Snowman with Ethereum block format
- See: LIP-12 for detailed specification

#### Specialized Chains

**M-Chain (Money/MPC Chain)**
- Purpose: Secure cross-chain asset management
- Key Features: CGG21 threshold MPC, Teleport Protocol, bridge governance
- Validators: Top 100 stakers who opt-in
- See: LIP-13 for detailed specification

**Z-Chain (Zero-Knowledge Chain)**
- Purpose: Privacy, cryptographic proofs, and omnichain coordination
- Key Features: zkEVM, FHE operations, zkBridge, AI/ML attestations
- Validators: Subset with specialized hardware (GPU/TEE)
- See: LIP-14 for detailed specification

### Key Protocols

1. **Teleport Protocol** (M-Chain): Native cross-chain transfers without wrapped tokens
2. **zkBridge Protocol** (Z-Chain): Privacy-preserving cross-chain transfers
3. **Settlement Protocol** (X-Chain): Unified liquidity and accounting
4. **LX Exchange Protocol**: High-performance on-chain trading (see LIP-3)

### Validator Architecture

| Tier | Stake Requirement | Chains | Hardware |
|------|------------------|---------|----------|
| Primary | 2,000+ LUX | P, X, C | Standard |
| M-Chain | 1,000,000+ LUX | P, X, C, M | Enhanced |
| Z-Chain | 100,000+ LUX | P, X, C, M, Z | Specialized (GPU/TEE) |

## Part 2: Community Contribution Framework

### Scope of Contributions

Community members can contribute to:

1. **Core Infrastructure**: Node software, consensus mechanisms, chain implementations
2. **Development Tools**: SDKs, CLI tools, testing frameworks
3. **Standards & Protocols**: Token standards (LRCs), wallet interfaces, DeFi protocols
4. **Applications**: Wallets, exchanges, DeFi platforms, explorers
5. **Documentation**: Technical docs, tutorials, translations
6. **Security**: Audits, vulnerability reports, security tools

### Repository Organization

All Lux Network code is organized under the [GitHub organization](https://github.com/luxdefi):

#### Core Infrastructure Repositories
- `node`: Core blockchain node (Go)
- `evm`: EVM implementation (Go)
- `bridge`: MPC bridge implementation
- `simplex`: Consensus mechanism
- `vmsdk`: Virtual Machine SDK

#### Development Tools
- `sdk`: JavaScript SDK
- `cli`: Command-line interface
- `kit`: Development kit
- `standard`: Smart contract library

#### Applications
- `wallet`: Multi-platform wallet
- `exchange`: Trading platform
- `explorer`: Block explorer
- `safe`: Multi-signature wallet

### Contribution Process

#### 1. Getting Started
```bash
# Fork the repository
# Clone your fork
git clone https://github.com/YOUR_USERNAME/REPO_NAME
# Add upstream remote
git remote add upstream https://github.com/luxdefi/REPO_NAME
# Create feature branch
git checkout -b feature/your-feature-name
```

#### 2. Development Workflow
1. **Discuss First**: For major changes, open an issue or discussion
2. **Follow Standards**: Adhere to language-specific style guides
3. **Write Tests**: Include comprehensive test coverage
4. **Document Changes**: Update relevant documentation
5. **Sign Commits**: Use GPG signing for security

#### 3. Submitting Changes
1. Push to your fork
2. Create pull request to `develop` branch
3. Ensure CI passes
4. Respond to review feedback
5. Maintainer merges when approved

### Code Standards

**Go Projects**
- Follow [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- Use `gofmt` and `golangci-lint`
- Minimum 80% test coverage

**Solidity Projects**
- Follow [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- Use latest stable compiler
- Include comprehensive tests

**JavaScript/TypeScript**
- ESLint configuration in repo
- Prettier for formatting
- Jest for testing

### LIP Process

For protocol changes and standards:

1. **Idea Discussion**: Post on forum.lux.network
2. **Draft LIP**: Use `./scripts/new-lip.sh` or `make new`
3. **Submit PR**: PR number becomes LIP number
4. **Review Process**: Technical and community review
5. **Implementation**: Build reference implementation
6. **Finalization**: Move to Final status

### Recognition & Incentives

1. **Contributor Recognition**: Listed in releases and documentation
2. **Bounty Program**: LUX rewards for specific tasks
3. **Grants**: Funding for larger projects
4. **Core Contributor Status**: For consistent contributors

### Security Considerations

1. **Responsible Disclosure**: Report vulnerabilities privately
2. **Security Reviews**: All PRs undergo security review
3. **Audit Requirements**: Major changes require external audit
4. **Bug Bounties**: Rewards for finding vulnerabilities

### Communication Channels

- **GitHub**: Primary development platform
- **Forum**: forum.lux.network for discussions
- **Discord**: Real-time community chat
- **Twitter**: @luxdefi for announcements

## Implementation Roadmap

### Phase 1: Foundation (Q1 2025)
- Core infrastructure LIPs (1-9)
- Chain specifications (10-14)
- Bridge protocols (15-19)

### Phase 2: Standards (Q2 2025)
- Token standards (20-39)
- Wallet standards (40-49)
- Developer tools (50-59)

### Phase 3: Applications (Q3 2025)
- DeFi protocols (60-79)
- Infrastructure tools (80-89)

### Phase 4: Advanced (Q4 2025+)
- Research initiatives (90-99)
- NFT standards (721+)
- Future expansions

## Governance

### LIP Governance
- **Proposal**: 10M LUX required
- **Voting Period**: 7 days
- **Approval**: 75% threshold
- **Implementation**: After Final status

### Network Governance
- **Parameter Changes**: Via governance proposals
- **Emergency Actions**: Multisig committee
- **Upgrades**: Coordinated through LIPs

## Specification

This meta-LIP establishes two core specifications for the Lux Network:

1. **Network Architecture Specification**: As detailed in Part 1, defining the 5-chain architecture
2. **Community Framework Specification**: As detailed in Part 2, defining contribution processes

The full specification is contained within the sections above.

## Rationale

### Network Architecture Rationale

The 5-chain architecture was chosen to:
- **Separate Concerns**: Each chain optimizes for specific use cases
- **Enable Parallelism**: Multiple chains can process transactions simultaneously
- **Maintain Security**: Specialized validators for high-security operations
- **Support Innovation**: New chains can be added without disrupting existing ones

### Community Framework Rationale

The contribution framework is designed to:
- **Lower Barriers**: Make it easy for developers to contribute
- **Maintain Quality**: Ensure code meets security and performance standards
- **Encourage Innovation**: Reward meaningful contributions
- **Build Community**: Foster long-term engagement

## Backwards Compatibility

As the foundational LIP, this document establishes the initial standards. Future changes to this meta-LIP will:
- Maintain compatibility with existing LIP processes
- Provide migration paths for any structural changes
- Announce deprecations with sufficient notice

## Security Considerations

### Network Security
- Multi-chain architecture isolates risks between chains
- Specialized validators for high-security operations (M-Chain, Z-Chain)
- Economic incentives align validator behavior with network security

### Contribution Security
- All code contributions undergo security review
- Responsible disclosure process for vulnerabilities
- External audits required for consensus-critical changes

## References

- [Lux Network Whitepaper](https://lux.network/whitepaper)
- [GitHub Organization](https://github.com/luxdefi)
- [Developer Documentation](https://docs.lux.network)
- Individual LIPs for detailed specifications

## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).