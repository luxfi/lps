---
lip: 27
title: 'LRC Token Standards Adoption'
description: Adopts and rebrands key Ethereum Request for Comment (ERC) token standards as Lux Request for Comment (LRC) standards for the Lux ecosystem.
author: Gemini (@gemini)
discussions-to: <URL to be created>
status: Draft
type: Standards Track
category: LRC
created: 2025-07-22
requires: 26
---

## Abstract

To ensure seamless compatibility, developer familiarity, and a unified brand identity, this LIP formalizes the adoption of essential Ethereum token standards as Lux Request for Comment (LRC) standards. This proposal specifies the direct mapping of the most widely-used ERCs to their LRC counterparts (e.g., ERC-20 becomes LRC-20). It defines the canonical interfaces for these standards and designates the contracts within the `/standard` repository as the official reference implementation for the Lux ecosystem.

## Motivation

A standardized token interface is the bedrock of a composable DeFi and NFT ecosystem. Smart contracts must be able to interact with any token in a predictable way. By adopting the battle-tested ERC standards, we:

*   **Lower the Barrier to Entry:** Developers familiar with Ethereum can build on Lux with zero learning curve for token interactions.
*   **Enable Instant Composability:** All wallets, dApps, and protocols on Lux can support any LRC token from day one.
*   **Establish a Unified Brand:** Using the "LRC" prefix clearly identifies tokens that adhere to the official Lux Network standard, enhancing trust and clarity.
*   **Avoid Reinventing the Wheel:** We leverage years of community vetting and security audits that have gone into the core Ethereum standards.

## Specification

This LIP establishes the following standards as official for the Lux Network.

### 1. LRC-20: Fungible Token Standard

*   **Maps to:** `ERC-20`
*   **Description:** The foundational standard for fungible tokens. Represents interchangeable assets like stablecoins, governance tokens, and utility tokens.
*   **Interface (`ILRC20.sol`):**
    ```solidity
    interface ILRC20 {
        function totalSupply() external view returns (uint256);
        function balanceOf(address account) external view returns (uint256);
        function transfer(address recipient, uint256 amount) external returns (bool);
        function allowance(address owner, address spender) external view returns (uint256);
        function approve(address spender, uint256 amount) external returns (bool);
        function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
    }
    ```
*   **Reference Implementation:** `/standard/src/tokens/LRC20.sol` (to be created/renamed)

### 2. LRC-721: Non-Fungible Token Standard

*   **Maps to:** `ERC-721`
*   **Description:** The core standard for unique, non-fungible tokens (NFTs). Used for digital art, collectibles, and unique identifiers.
*   **Interface (`ILRC721.sol`):**
    ```solidity
    interface ILRC721 {
        function balanceOf(address owner) external view returns (uint256 balance);
        function ownerOf(uint256 tokenId) external view returns (address owner);
        function transferFrom(address from, address to, uint256 tokenId) external;
        function approve(address to, uint256 tokenId) external;
        function getApproved(uint256 tokenId) external view returns (address operator);
        function setApprovalForAll(address operator, bool _approved) external;
        function isApprovedForAll(address owner, address operator) external view returns (bool);

        event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
        event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
        event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    }
    ```
*   **Reference Implementation:** `/standard/src/LRC721.sol` (to be renamed from `ERC721.sol`)

### 3. LRC-1155: Multi-Token Standard

*   **Maps to:** `ERC-1155`
*   **Description:** A standard for contracts that manage multiple token types. A single LRC-1155 contract can represent any combination of fungible and non-fungible tokens. Ideal for gaming items and batched transfers.
*   **Reference Implementation:** To be added to the `/standard` repository.

## Rationale

The selected standards (20, 721, 1155) represent the three most critical and widely adopted token interfaces in the Ethereum ecosystem. By focusing on these, we cover the vast majority of use cases. The mapping is a direct 1-to-1 adoption of the interfaces to ensure zero friction for developers. The "LRC" branding is a simple but important step in building the Lux ecosystem's identity.

## Backwards Compatibility

This proposal is fully backwards compatible. It simply formalizes and rebrands existing de-facto standards. Any contract currently compliant with ERC-20 or ERC-721 is, by definition, compliant with LRC-20 and LRC-721.

## Security Considerations

The security of the LRC standards is inherited from their ERC counterparts. These standards are widely considered secure. The primary security responsibility lies with the implementers of individual token contracts to ensure they adhere to the standard correctly and do not introduce vulnerabilities in their own business logic.

## Reference Implementation

The canonical reference implementations for all LRC standards will be maintained in the `/standard` repository. This LIP mandates the renaming and structuring of the files within that repository to match the LRC standard names (e.g., `ERC721.sol` will be renamed to `LRC721.sol`).
