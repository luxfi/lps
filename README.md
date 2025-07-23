# Lux Improvement Proposals (LIPs)

<div align="center">
  <img src="resources/LuxLogoRed.png?raw=true" alt="Lux Network" width="300">
</div>

---

This repository contains all Lux Improvement Proposals (LIPs) - the primary mechanism for proposing new features, collecting community input, and documenting design decisions for the Lux Network.

## What is a LIP?

A Lux Improvement Proposal (LIP) is a design document providing information to the Lux community about a proposed change to the system. LIPs are the primary mechanism for:
- Proposing new features and standards
- Collecting community technical input
- Documenting design decisions

## Quick Start

- 📖 **New to LIPs?** Start with [LIP-0](LIPs/lip-0.md) for architecture overview and contribution guidelines
- 🚀 **Create a new LIP:** Run `make new` or `./scripts/new-lip.sh`
- 📋 **View all LIPs:** See [INDEX.md](INDEX.md) for complete documentation
- 🔍 **Check status:** See [STATUS.md](STATUS.md) for current LIP statuses

## LIP Index

### Foundation & Governance (0-9)
| LIP | Title | Status | Type |
|-----|-------|--------|------|
| [0](LIPs/lip-0.md) | Lux Network Architecture & Community Framework | Final | Meta |
| [1](LIPs/lip-1.md) | Native LUX Token Standard | Draft | Standards Track |
| [2](LIPs/lip-2.md) | Liquidity Pool Standard | Draft | Standards Track |
| [3](LIPs/lip-3.md) | LX Exchange Protocol | Draft | Standards Track |
| [4](LIPs/lip-4.md) | Core Consensus and Node Architecture | Draft | Standards Track |

### Chain Specifications (10-14)
| LIP | Title | Status | Type |
|-----|-------|--------|------|
| [10](LIPs/lip-10.md) | P-Chain (Platform Chain) Specification | Draft | Standards Track |
| [11](LIPs/lip-11.md) | X-Chain (Exchange Chain) Specification | Draft | Standards Track |
| [12](LIPs/lip-12.md) | C-Chain (Contract Chain) EVM Specification | Draft | Standards Track |
| [13](LIPs/lip-13.md) | M-Chain (MPC Bridge Chain) Specification | Draft | Standards Track |
| [14](LIPs/lip-14.md) | Z-Chain (Zero-Knowledge Chain) Specification | Draft | Standards Track |

### Token Standards (20-39)
| LIP | Title | Status | Type |
|-----|-------|--------|------|
| [20](LIPs/lip-20.md) | LRC-20 Fungible Token Standard | Draft | Standards Track |
| [21](LIPs/lip-21.md) | LRC-21 Payable Token Extension | Draft | Standards Track |
| [22](LIPs/lip-22.md) | LRC-22 Permit Extension | Draft | Standards Track |
| ... | [See full list](STATUS.md) | ... | ... |

### Wallet & Security Standards (40-49)
| LIP | Title | Status | Type |
|-----|-------|--------|------|
| [40](LIPs/lip-40.md) | Wallet Interface Standard | Draft | Standards Track |
| [42](LIPs/lip-42.md) | Multi-Signature Wallet Standard | Draft | Standards Track |

### Developer Tools (50-59)
| LIP | Title | Status | Type |
|-----|-------|--------|------|
| [50](LIPs/lip-50.md) | JavaScript SDK Specification | Draft | Standards Track |

### DeFi Protocols (60-79)
| LIP | Title | Status | Type |
|-----|-------|--------|------|
| [60](LIPs/lip-60.md) | Lending Protocol Standard (Alchemix-based) | Draft | Standards Track |
| [61](LIPs/lip-61.md) | Automated Market Maker (AMM) Standard | Draft | Standards Track |
| [62](LIPs/lip-62.md) | Yield Farming Protocol Standard | Draft | Standards Track |
| [63](LIPs/lip-63.md) | NFT Marketplace Protocol Standard | Draft | Standards Track |
| [64](LIPs/lip-64.md) | Tokenized Vault Standard (LRC-4626) | Draft | Standards Track |
| [65](LIPs/lip-65.md) | Multi-Token Standard (LRC-6909) | Draft | Standards Track |
| [66](LIPs/lip-66.md) | Oracle Integration Standard via Z-Chain | Draft | Standards Track |
| [67](LIPs/lip-67.md) | Asynchronous Vault Standard (LRC-7540) | Draft | Standards Track |
| [68](LIPs/lip-68.md) | Bonding Curve AMM Standard | Draft | Standards Track |

### Infrastructure & Operations (80-89)
| LIP | Title | Status | Type |
|-----|-------|--------|------|
| [81](LIPs/lip-81.md) | Indexer API Standard (Blockscout-based) | Draft | Standards Track |
| [85](LIPs/lip-85.md) | Security Audit Framework | Draft | Standards Track |

### Research Papers (90-99)
| LIP | Title | Status | Type |
|-----|-------|--------|------|
| [90](LIPs/lip-90.md) | NFT Marketplace Research | Draft | Informational |
| [91](LIPs/lip-91.md) | Payment Processing Research | Draft | Informational |
| [92](LIPs/lip-92.md) | Cross-Chain Messaging Research | Draft | Informational |
| [93](LIPs/lip-93.md) | Decentralized Identity Research | Draft | Informational |
| [94](LIPs/lip-94.md) | Governance Framework Research | Draft | Informational |
| [95](LIPs/lip-95.md) | Stablecoin Mechanisms Research | Draft | Informational |
| [96](LIPs/lip-96.md) | MEV Protection Research | Draft | Informational |
| [97](LIPs/lip-97.md) | Data Availability Research | Draft | Informational |

### Advanced Standards (721+)
| LIP | Title | Status | Type |
|-----|-------|--------|------|
| [721](LIPs/lip-721.md) | LRC-721 Non-Fungible Token Standard | Draft | Standards Track |
| [1155](LIPs/lip-1155.md) | LRC-1155 Multi-Token Standard | Draft | Standards Track |

## LIP Process

1. **💡 Have an idea** - Start with community discussion on [forum.lux.network](https://forum.lux.network)
2. **📝 Draft your LIP** - Use `make new` to create from template
3. **🔄 Submit PR** - Your PR number becomes your LIP number
4. **👥 Get reviewed** - LIP editors review for completeness
5. **🗳️ Build consensus** - Community discussion and feedback
6. **⏰ Last Call** - 14-day final review period
7. **✅ Final** - LIP is finalized and ready for implementation

## Types of LIPs

- **Standards Track**: Technical specifications affecting protocol
  - Core: Consensus and network changes
  - Networking: P2P and network layer
  - Interface: API/RPC specifications
  - LRC: Application-layer standards (tokens, NFTs, etc.)
- **Meta**: Process and governance proposals
- **Informational**: Guidelines and best practices

## Tools and Commands

We provide a Makefile and scripts to help manage LIPs:

```bash
# Create a new LIP
make new

# Validate a LIP
make validate FILE=LIPs/lip-20.md

# Validate all LIPs
make validate-all

# Check all links
make check-links

# Update the index
make update-index

# Show LIP statistics
make stats

# Run all checks before PR
make pre-pr
```

## Development Roadmap

The Lux Network follows a phased development approach:

- **Phase 1** (Q1 2025): Foundational Governance & Core Protocol
- **Phase 2** (Q2 2025): Execution Environment & Asset Standards
- **Phase 3** (Q3 2025): Cross-Chain Interoperability
- **Phase 4** (Q4 2025): Attestations & Compliance
- **Phase 5** (Q1 2026): Privacy & Zero-Knowledge
- **Phase 6** (Q2 2026): Data Availability & Scalability
- **Phase 7** (Q3 2026+): Application Layer Standards

See [phases/](phases/) for detailed roadmap information.

## Contributing

We welcome contributions! Please see:
- [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
- [LIP-0](LIPs/lip-0.md) for the community framework
- [GOVERNANCE.md](GOVERNANCE.md) for governance processes

## Resources

- 🌐 **Forum**: [forum.lux.network](https://forum.lux.network)
- 📚 **Documentation**: [docs.lux.network](https://docs.lux.network)
- 💬 **Discord**: [discord.gg/lux](https://discord.gg/lux)
- 🐦 **Twitter**: [@luxdefi](https://twitter.com/luxdefi)

## License

All LIPs are released under [CC0 1.0 Universal](LICENSE.md).

---

<div align="center">
  <strong>Building the future of decentralized finance, one proposal at a time.</strong>
</div>