# Lux Improvement Proposals (LIPs)

<div align="center">
  <img width="80%" src="https://lux.network/logo.png" alt="Lux Network">
</div>

## TL;DR

- **LIP = Lux Improvement Proposal** – the canonical process and document format for any change or guideline in the Lux Network ecosystem.
- **LRC = Lux Request for Comment** – a subcategory of Standards-Track LIPs dedicated to application-layer and smart-contract standards (e.g., token contracts, signature formats).
- **Every LRC is a LIP**, but only Standards-Track LIPs whose front-matter reads `category: LRC` get an LRC number.

---

## 1. What is a Lux Improvement Proposal (LIP)?

Lux Network follows the same pattern pioneered by Ethereum and later adopted by other L1s: an Improvement Proposal is "a design document providing information to the community or describing a new feature, process, or environment change." The public template shows that every LIP front-matter specifies:

```yaml
type:     (Standards Track | Meta | Informational)
category: (Core | Networking | Interface | LRC)   # only for Standards Track
status:   (Draft → Review → Last Call → Final)
```

The template mirrors the EIP header and life-cycle—Draft, Review, Last Call, Final, etc.—so contributors know exactly how to move a proposal forward.

### LIP types at a glance

| Type | Purpose | Examples |
|------|---------|----------|
| **Standards Track** | Technical specs that affect interoperability | VM op-codes, JSON-RPC additions |
| **Meta** | Changes to governance, tooling, or the LIP process itself | Editor rules, version-bump policies |
| **Informational** | Non-binding research or best-practice docs | Economic analyses, threat models |

Within Standards Track LIPs there are four categories—**Core**, **Networking**, **Interface**, and **LRC**—exactly mirroring the EIP taxonomy where ERC plays the role reserved for LRC.

---

## 2. What is a Lux Request for Comment (LRC)?

**LRCs are simply the LRC category of Standards-Track LIPs.**

They exist to standardise application-level conventions so that wallets, dApps, indexers, and block explorers can interoperate without bespoke glue code. Typical scopes include:

- **Token interfaces** (fungible, non-fungible, or soul-bound variants)
- **Wallet/account abstraction** (e.g., delegated execution, social recovery)
- **Off-chain message formats** (permit signatures, typed-data hashing)
- **URI schemes or registry contracts** (name services, metadata pointers)

When such a proposal is merged, the document is stored in the same Git repository as other LIPs but is referred to by its LRC-X shorthand (just as Ethereum uses ERC-20 for EIP-20).

### Header example

```yaml
lip: 27
title: LRC-27 Fungible Token Standard
type: Standards Track
category: LRC
status: Draft
created: 2025-07-19
```

---

## 3. How LIPs and LRCs relate

|  | **LIP (umbrella)** | **LRC (subcategory)** |
|---|---|---|
| **Layer affected** | Any (consensus to UX) | Application / smart-contract |
| **Who must upgrade?** | Core clients, node operators, or tooling | Contract authors & dApp integrators |
| **Need a hard-fork?** | Only for Core LIPs | Never – contracts opt-in |
| **Finality bar** | Multiple client implementations + consensus | ≥ 2 independent contract impls; no fork |
| **Citation form** | LIP-42 | LRC-42 |

---

## 4. Process differences in practice

Both artifacts share the same states (Draft → Review → Last Call → Final/Withdrawn). The fork-coordination burden falls exclusively on Core LIPs; in contrast, an LRC can reach Final once two or more contract implementations demonstrate interoperability and the editor confirms no outstanding technical objections. That keeps the consensus-layer agile while letting dApp developers iterate quickly on higher-level standards.

---

## 5. Naming confusion & best practice

Because Ethereum popularised the term "ERC-20," many people casually say "ERC" when they really mean "EIP." In Lux Network's case:

- Use **"LIP"** when you are talking about the proposal process.
- Use **"LRC"** only for application-layer standards.
- When citing, prefer the canonical form (**LIP-X**) in specifications, and the shorthand (**LRC-X**) in marketing or developer-facing docs.

### Key takeaway

Think of "LIP" as the governing process and repository, and "LRC" as the slice of that process devoted to contract-level standards. If your idea affects the smart-contract or dApp layer—tokens, NFTs, account abstraction—it belongs in an LRC; everything else is "just" another type of LIP.

---

## LIP Workflow

### Step 0: Have an idea
The LIP process begins with a new idea for Lux. Each potential LIP must have an author: someone who writes the LIP using the style and format described below, shepherds the discussions in the appropriate forums, and attempts to build community consensus around the idea.

### Step 1: Post to the forum
Before you begin writing a formal LIP, you should vet your idea. Ask the Lux community first if an idea is original to avoid wasting time on something that will be rejected based on prior research.

### Step 2: Propose a LIP via Pull Request
Once you've decided your idea has a good chance of acceptance, draft a LIP following the [template](./LIPs/TEMPLATE.md). Submit it as a pull request to this repository. The PR number becomes the LIP number.

### Step 3: Get Your LIP Reviewed
LIP editors will review your PR for structure, formatting, and other errors. Once approved by an editor, your LIP moves to Review status.

### Step 4: Build Community Consensus
Share your LIP with the community. Gather feedback, make improvements, and work towards consensus. For Core LIPs, you should reach out to client implementers. For LRCs, engage with dApp developers and wallet providers.

### Step 5: Move to Last Call
Once you've addressed feedback and believe your LIP is mature, you can request Last Call status. This starts a 14-day final review period.

### Step 6: Finalization
If no substantive changes arise during Last Call, your LIP moves to Final. For Core LIPs, this coincides with client implementations being ready. For LRCs, this requires at least two independent, interoperable implementations.

## What belongs in a successful LIP?

Each LIP should have the following parts:

- **Preamble**: YAML headers containing metadata about the LIP
- **Abstract**: A short (~200 word) description of the technical issue being addressed
- **Motivation**: The motivation should clearly explain why the existing protocol specification is inadequate
- **Specification**: The technical specification should describe the syntax and semantics of any new feature
- **Rationale**: The rationale fleshes out the specification by describing what motivated the design
- **Backwards Compatibility**: All LIPs that introduce backwards incompatibilities must include a section describing these
- **Test Cases**: Test cases for an implementation are mandatory for LIPs that are affecting consensus changes
- **Reference Implementation**: An optional section that contains a reference/example implementation
- **Security Considerations**: All LIPs must contain a section that discusses the security implications/considerations

## LIP Formats and Templates

LIPs should be written in [markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) format. Each LIP should be in its own file named `lip-N.md` where `N` is the LIP number. 

For LRCs, the file should still be named `lip-N.md` but the title should include the LRC designation (e.g., "LRC-20 Fungible Token Standard").

Image files should be included in a subdirectory of the `assets` folder: `assets/lip-N`.

Please see the [LIP template](./LIPs/TEMPLATE.md) for the correct format.

## Current Proposals

| Number | Title | Author(s) | Type | Category | Status |
|:-------|:------|:----------|:-----|:---------|:-------|
| [LIP-1](./LIPs/lip-1.md) | Community Contribution Framework | Lux Team | Meta | - | Review |
| [LIP-20](./LIPs/lip-20.md) | LRC-20 Fungible Token Standard | Lux Team | Standards Track | LRC | Draft |

### Notable LRCs (Application Standards)

| LRC Number | LIP | Title | Status |
|:-----------|:----|:------|:-------|
| LRC-20 | [LIP-20](./LIPs/lip-20.md) | Fungible Token Standard | Draft |

## Contributing

Before contributing to LIPs, please read the [LIP Terms of Contribution](./CONTRIBUTING.md) and review the [LIP template](./LIPs/TEMPLATE.md).

## LIP Editors

The current LIP editors are:
- *To be determined*

## LIP Editor Responsibilities

For each new LIP that comes in, an editor does the following:
- Read the LIP to check if it is ready: sound and complete
- Check if the LIP fits the format and template
- Check if the LIP has been properly discussed in forums
- Assign a LIP number and merge the PR
- For LRCs, also assign an LRC number (e.g., if LIP-27 is an LRC, it becomes LRC-27)

## Contact

- **Discord**: [Join our Discord](https://discord.gg/lux)
- **Forum**: [Lux Community Forum](https://forum.lux.network)
- **GitHub Discussions**: [LIP Discussions](https://github.com/luxfi/lips/discussions)

## License

This repository is licensed under [CC0 1.0 Universal](LICENSE).

## History

This document was derived heavily from [Ethereum's EIP process](https://eips.ethereum.org/EIPS/eip-1), which was derived from [Bitcoin's BIP process](https://github.com/bitcoin/bips), which was derived from [Python's PEP process](https://www.python.org/dev/peps/).

(This explanation is modelled on the publicly documented EIP/ERC framework, but Lux's exact categorisation may evolve. Always check the current CONTRIBUTING.md in the LIP repo before submitting.)