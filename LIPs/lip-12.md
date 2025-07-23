---
lip: 12
title: C-Chain (Contract Chain) EVM Specification
description: Defines the EVM-compatible Contract Chain specification for Lux Network
author: Lux Network Team (@luxdefi)
discussions-to: https://forum.lux.network/lip-12
status: Draft
type: Standards Track
category: Core
created: 2025-01-22
updated: 2025-01-23
requires: 0, 4
---  

## Abstract

This LIP specifies the C-Chain's Ethereum Virtual Machine (EVM) implementation, including full Ethereum compatibility, adopted ERC standards, Lux-specific extensions, and future OP-Stack integration plans. The C-Chain serves as Lux Network's smart contract platform.

## Motivation

EVM compatibility provides:
1. **Developer Adoption**: Familiar tooling and languages
2. **Ecosystem Access**: Existing dApps and infrastructure
3. **Network Effects**: Liquidity and user base
4. **Innovation Platform**: Build on proven foundation

## Specification

### 1. Core EVM Implementation

#### 1.1 Base Compatibility

C-Chain runs a modified version of go-ethereum (geth) called coreth:

```go
// Coreth modifications to geth
type VM struct {
    eth.Backend
    
    // Lux-specific additions
    codec          codec.Manager
    clock          *mockable.Clock
    mempool        *Mempool
    
    // Consensus integration
    toEngine       chan<- Message
    bootstrapped   bool
}
```

**Ethereum Compatibility Level**: Berlin hard fork + custom features

#### 1.2 Differences from Ethereum

| Feature | Ethereum | C-Chain |
|---------|----------|---------|
| Consensus | Proof of Stake | Avalanche (Snowman) |
| Block Time | ~12 seconds | ~2 seconds |
| Finality | ~15 minutes | ~2 seconds |
| Gas Token | ETH | LUX |
| Chain ID | 1 (mainnet) | 43114 (mainnet) |

### 2. Supported Standards

#### 2.1 Token Standards

**LRC-20 (≡ ERC-20)**: Fungible Tokens
```solidity
interface ILRC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
```

**LRC-721 (≡ ERC-721)**: Non-Fungible Tokens
```solidity
interface ILRC721 {
    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
```

**LRC-1155 (≡ ERC-1155)**: Multi-Token Standard
```solidity
interface ILRC1155 {
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
}
```

#### 2.2 Additional Standards

- **LRC-165**: Interface Detection
- **LRC-777**: Advanced Token Standard
- **LRC-1820**: Registry Standard
- **LRC-2981**: NFT Royalty Standard
- **LRC-4626**: Tokenized Vault Standard

### 3. Lux-Specific Extensions

#### 3.1 Native Asset Precompiles

C-Chain can interact with X-Chain assets via precompiles:

```solidity
// Precompile at 0x0200000000000000000000000000000000000001
interface INativeMinter {
    function mintNativeCoin(address recipient, uint256 amount) external;
    function burnNativeCoin(uint256 amount) external;
}

// Precompile at 0x0200000000000000000000000000000000000002
interface IXChainBridge {
    function exportToXChain(address asset, uint256 amount, bytes32 to) external;
    function importFromXChain(bytes32 sourceAddress) external returns (uint256);
}
```

#### 3.2 Warp Messaging Precompile

Fast cross-subnet communication:

```solidity
// Precompile at 0x0200000000000000000000000000000000000005
interface IWarpMessenger {
    function sendWarpMessage(bytes calldata payload) external returns (bytes32 messageID);
    function getVerifiedWarpMessage(uint32 index) external view returns (WarpMessage memory);
}
```

#### 3.3 Staking Precompiles

Direct staking from C-Chain:

```solidity
// Precompile at 0x0200000000000000000000000000000000000003
interface IStakingManager {
    function delegate(bytes32 nodeID, uint256 amount) external;
    function undelegate(bytes32 nodeID) external;
    function claimRewards() external returns (uint256);
}
```

### 4. Gas Mechanics

#### 4.1 Gas Pricing

C-Chain uses dynamic fees similar to EIP-1559:

```go
type FeeConfig struct {
    GasLimit        *big.Int `json:"gasLimit"`
    TargetBlockRate uint64   `json:"targetBlockRate"` // 2 seconds
    MinBaseFee      *big.Int `json:"minBaseFee"`      // 25 nLUX
    TargetGas       *big.Int `json:"targetGas"`       // 15M gas
    BaseFeeChangeDenominator *big.Int
    MaxBlockGasCost *big.Int
}
```

#### 4.2 Gas Schedule

| Operation | Gas Cost | Notes |
|-----------|----------|--------|
| Basic Transfer | 21,000 | Same as Ethereum |
| LRC-20 Transfer | ~50,000 | Depends on implementation |
| Contract Deploy | Variable | Based on code size |
| Cross-chain Export | 100,000 | Via precompile |
| Warp Message | 50,000 | Subnet communication |

### 5. Network Parameters

```solidity
// Network configuration
contract NetworkParams {
    uint256 constant CHAIN_ID = 43114;          // C-Chain mainnet
    uint256 constant BLOCK_GAS_LIMIT = 15_000_000;
    uint256 constant BLOCK_TIME = 2 seconds;
    
    address constant NATIVE_MINTER = 0x0200000000000000000000000000000000000001;
    address constant CONTRACT_DEPLOYER_ALLOW_LIST = 0x0200000000000000000000000000000000000002;
    address constant TX_ALLOW_LIST = 0x0200000000000000000000000000000000000003;
    address constant FEE_MANAGER = 0x0200000000000000000000000000000000000004;
    address constant WARP_MESSENGER = 0x0200000000000000000000000000000000000005;
}
```

### 6. Development Tools

#### 6.1 Compatible Tools

- **Wallets**: MetaMask, Core, WalletConnect
- **IDEs**: Remix, Hardhat, Foundry, Truffle
- **Libraries**: Web3.js, Ethers.js, Viem
- **Indexers**: The Graph, Covalent
- **Oracles**: Chainlink, Band Protocol

#### 6.2 RPC Endpoints

```javascript
// Mainnet
const mainnetRPC = "https://api.lux.network/ext/bc/C/rpc";

// Testnet
const testnetRPC = "https://api.lux-test.network/ext/bc/C/rpc";

// WebSocket
const mainnetWS = "wss://api.lux.network/ext/bc/C/ws";
```

### 7. Smart Contract Best Practices

#### 7.1 Gas Optimization

```solidity
// Optimize for 2-second blocks
contract GasOptimized {
    // Pack structs
    struct User {
        uint128 balance;    // Slot 1
        uint64 lastUpdate;  // Slot 1
        uint64 nonce;       // Slot 1
        address owner;      // Slot 2
    }
    
    // Use events for data storage
    event DataStored(address indexed user, bytes data);
    
    // Batch operations
    function batchTransfer(address[] calldata recipients, uint256[] calldata amounts) external {
        require(recipients.length == amounts.length, "Length mismatch");
        for (uint i = 0; i < recipients.length; i++) {
            _transfer(recipients[i], amounts[i]);
        }
    }
}
```

#### 7.2 Cross-Chain Integration

```solidity
contract CrossChainEnabled {
    IXChainBridge constant bridge = IXChainBridge(0x0200000000000000000000000000000000000002);
    IWarpMessenger constant warp = IWarpMessenger(0x0200000000000000000000000000000000000005);
    
    function bridgeToXChain(uint256 amount) external {
        // Export LUX to X-Chain
        bridge.exportToXChain(address(0), amount, keccak256(abi.encode(msg.sender)));
    }
    
    function sendCrossSubnetMessage(uint32 destinationChain, bytes calldata message) external {
        warp.sendWarpMessage(abi.encode(destinationChain, message));
    }
}
```

### 8. Future OP-Stack Integration

C-Chain is being prepared for OP-Stack L2 support:

```solidity
// Future L2 deployment interface
interface IL2Deployer {
    struct L2Config {
        uint256 blockTime;
        uint256 sequencerWindow;
        address sequencer;
        address proposer;
        address challenger;
    }
    
    function deployL2(L2Config calldata config) external returns (address rollup);
    function pauseL2(address rollup) external;
    function upgradeL2(address rollup, address newImpl) external;
}
```

### 9. Security Considerations

#### 9.1 Reentrancy Protection

```solidity
// Use OpenZeppelin ReentrancyGuard or custom modifier
modifier nonReentrant() {
    require(!locked, "Reentrant call");
    locked = true;
    _;
    locked = false;
}
```

#### 9.2 Cross-Chain Security

```solidity
// Validate cross-chain messages
function processCrossChainMessage(bytes calldata message, bytes calldata proof) external {
    require(warp.verifyMessage(message, proof), "Invalid proof");
    // Process message
}
```

## Migration Guide

### From Ethereum to C-Chain

1. **Update Chain ID**: Change from 1 to 43114
2. **Update RPC**: Use Lux RPC endpoints
3. **Update Gas Token**: ETH → LUX
4. **Test Precompiles**: Verify Lux-specific features

### Contract Deployment

```javascript
// Deploy with Hardhat
module.exports = {
  networks: {
    "c-chain": {
      url: "https://api.lux.network/ext/bc/C/rpc",
      chainId: 43114,
      accounts: [process.env.PRIVATE_KEY]
    }
  }
};
```

## Compliance

C-Chain maintains compatibility with:
- **EIP-155**: Replay attack protection
- **EIP-1559**: Dynamic fees
- **EIP-2718**: Typed transactions
- **EIP-2930**: Access lists

## Future Enhancements

1. **OP-Stack Integration** (LIP-007)
2. **Account Abstraction** (EIP-4337)
3. **Proto-danksharding** (EIP-4844)
4. **EOF** (EVM Object Format)

## Copyright

Copyright and related rights waived via CC0.