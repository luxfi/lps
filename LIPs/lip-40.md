---
lip: 40
title: Wallet Interface Standard
description: Defines the standard interface for wallets interacting with Lux Network
author: Lux Network Team (@luxdefi)
discussions-to: https://forum.lux.network/lip-40
status: Draft
type: Standards Track
category: Interface
created: 2025-01-23
requires: 1, 20
---

## Abstract

This LIP defines a standard interface for wallets interacting with the Lux Network, ensuring consistent user experiences and developer integration across all wallet implementations. The standard covers provider interfaces, connection protocols, message signing, transaction handling, and multi-chain support.

## Motivation

The Lux ecosystem has multiple wallet implementations (wallet, monowallet, extension, safe, ledger) but lacks a unified standard for:

1. **Developer Experience**: Inconsistent APIs across wallets complicate dApp development
2. **User Experience**: Different connection flows confuse users
3. **Security**: Varying security practices create vulnerabilities
4. **Multi-Chain Support**: No standard for handling Lux's 5-chain architecture
5. **Feature Parity**: Wallets implement features differently or incompletely

## Specification

### Core Wallet Provider Interface

```typescript
interface LuxProvider extends EventEmitter {
  // Provider identification
  readonly isLux: true;
  readonly version: string;
  readonly name: string;
  readonly icon: string;
  
  // Connection management
  connect(): Promise<ConnectionInfo>;
  disconnect(): Promise<void>;
  isConnected(): boolean;
  
  // Account management
  requestAccounts(): Promise<Account[]>;
  getAccounts(): Promise<Account[]>;
  
  // Chain management
  getCurrentChain(): Promise<ChainInfo>;
  switchChain(chainId: string): Promise<void>;
  addChain(chainConfig: ChainConfig): Promise<void>;
  
  // Transaction handling
  sendTransaction(tx: TransactionRequest): Promise<TransactionResponse>;
  signTransaction(tx: TransactionRequest): Promise<SignedTransaction>;
  
  // Message signing
  signMessage(message: string | Uint8Array): Promise<string>;
  signTypedData(domain: TypedDataDomain, types: TypedDataTypes, value: any): Promise<string>;
  
  // Lux-specific features
  getLuxBalance(address: string, chainId?: string): Promise<bigint>;
  getAssetBalance(address: string, assetId: string, chainId?: string): Promise<bigint>;
  
  // Events
  on(event: 'accountsChanged', handler: (accounts: string[]) => void): void;
  on(event: 'chainChanged', handler: (chainId: string) => void): void;
  on(event: 'connect', handler: (info: ConnectionInfo) => void): void;
  on(event: 'disconnect', handler: (error?: Error) => void): void;
}
```

### Account Structure

```typescript
interface Account {
  address: string;           // Bech32 address for X/P chains, 0x for C-Chain
  publicKey: string;         // Hex-encoded public key
  chainId: string;           // Current chain (P, X, C, M, Z)
  type: AccountType;         // 'secp256k1' | 'bls' | 'quantum-safe'
  derivationPath?: string;   // For HD wallets
  label?: string;            // User-defined label
}

enum AccountType {
  SECP256K1 = 'secp256k1',    // Standard
  BLS = 'bls',                // For validators
  QUANTUM_SAFE = 'quantum-safe' // For Z-Chain
}
```

### Chain Configuration

```typescript
interface ChainInfo {
  chainId: string;           // 'P' | 'X' | 'C' | 'M' | 'Z' | custom
  chainName: string;
  nativeCurrency: {
    name: string;
    symbol: string;
    decimals: number;
  };
  rpcUrls: string[];
  blockExplorerUrls?: string[];
  iconUrls?: string[];
  vmType: 'platform' | 'avm' | 'evm' | 'mpc' | 'zk';
}

interface ChainConfig extends ChainInfo {
  // Additional fields for adding custom chains
  parentChainId?: string;    // For subnets
  feeConfig?: FeeConfig;
  consensusParameters?: any;
}
```

### Transaction Handling

```typescript
interface TransactionRequest {
  from: string;
  to?: string;               // Optional for contract deployment
  value?: bigint;            // Amount in wei/nLUX
  data?: string;             // Hex-encoded data
  
  // Chain-specific
  chainId: string;
  type?: TransactionType;
  
  // Gas (C-Chain)
  gasLimit?: bigint;
  gasPrice?: bigint;
  maxFeePerGas?: bigint;
  maxPriorityFeePerGas?: bigint;
  
  // X-Chain specific
  assetId?: string;
  outputs?: Output[];
  memo?: string;
  
  // Cross-chain
  sourceChain?: string;
  destinationChain?: string;
}

enum TransactionType {
  // P-Chain
  ADD_VALIDATOR = 'addValidator',
  ADD_DELEGATOR = 'addDelegator',
  CREATE_SUBNET = 'createSubnet',
  
  // X-Chain
  BASE_TX = 'baseTx',
  CREATE_ASSET = 'createAsset',
  OPERATION_TX = 'operationTx',
  
  // C-Chain
  LEGACY = 0,
  EIP2930 = 1,
  EIP1559 = 2,
  
  // Cross-chain
  IMPORT = 'import',
  EXPORT = 'export',
  
  // M-Chain
  BRIDGE_TRANSFER = 'bridgeTransfer',
  
  // Z-Chain
  PRIVATE_TRANSFER = 'privateTransfer'
}
```

### Connection Protocol

```typescript
interface ConnectionInfo {
  accounts: Account[];
  chainId: string;
  features: WalletFeatures;
}

interface WalletFeatures {
  // Core features
  signMessage: boolean;
  signTypedData: boolean;
  
  // Multi-chain
  multiChain: boolean;
  crossChain: boolean;
  
  // Advanced
  hardwareWallet: boolean;
  multiSig: boolean;
  smartContract: boolean;
  
  // Lux-specific
  staking: boolean;
  subnets: boolean;
  bridging: boolean;
  privacy: boolean;
}
```

### Message Signing

```typescript
// EIP-712 style typed data for C-Chain
interface TypedDataDomain {
  name?: string;
  version?: string;
  chainId?: number;
  verifyingContract?: string;
  salt?: string;
}

// Lux-specific message format
interface LuxMessage {
  version: number;
  chainId: string;
  from: string;
  timestamp: number;
  message: string;
  metadata?: Record<string, any>;
}
```

### Provider Discovery

```typescript
// Global injection
interface Window {
  lux?: LuxProvider;
  luxProviders?: LuxProvider[];
}

// EIP-6963 style provider announcement
interface ProviderInfo {
  uuid: string;
  name: string;
  icon: string;
  rdns: string;  // Reverse DNS
}

interface AnnounceProviderEvent extends CustomEvent {
  type: 'lux:announceProvider';
  detail: {
    info: ProviderInfo;
    provider: LuxProvider;
  };
}
```

### Error Handling

```typescript
enum WalletErrorCode {
  // Connection errors
  USER_REJECTED_REQUEST = 4001,
  UNAUTHORIZED = 4100,
  UNSUPPORTED_METHOD = 4200,
  DISCONNECTED = 4900,
  
  // Chain errors
  CHAIN_NOT_ADDED = 4902,
  UNRECOGNIZED_CHAIN = 4903,
  
  // Transaction errors
  INSUFFICIENT_FUNDS = -32000,
  TRANSACTION_REJECTED = -32003,
  INVALID_PARAMS = -32602,
  
  // Lux-specific
  INVALID_ASSET = -32010,
  STAKING_ERROR = -32011,
  BRIDGE_ERROR = -32012
}

class WalletError extends Error {
  code: WalletErrorCode;
  data?: any;
}
```

### Multi-Chain Operations

```typescript
interface MultiChainProvider extends LuxProvider {
  // Get providers for specific chains
  getChainProvider(chainId: string): ChainProvider;
  
  // Batch operations
  batchRequest(requests: RequestItem[]): Promise<any[]>;
  
  // Cross-chain operations
  transferCrossChain(params: CrossChainTransfer): Promise<string>;
  importFrom(sourceChain: string, destinationChain: string): Promise<string>;
  exportTo(sourceChain: string, destinationChain: string, amount: bigint): Promise<string>;
}

interface CrossChainTransfer {
  asset: string;
  amount: bigint;
  sourceChain: string;
  destinationChain: string;
  recipient?: string;  // Different address on destination
}
```

## Rationale

### Design Decisions

1. **EVM Compatibility**: C-Chain methods mirror Web3 standards for familiarity
2. **Multi-Chain First**: Native support for Lux's 5-chain architecture
3. **Event-Driven**: Consistent with modern wallet patterns
4. **Type Safety**: Full TypeScript definitions for better developer experience
5. **Extensibility**: Feature detection allows graceful degradation

### Security Considerations

1. **Origin Validation**: Wallets must validate dApp origins
2. **Permission Model**: Clear user consent for all operations
3. **Message Signing**: Structured data prevents signing arbitrary content
4. **Transaction Simulation**: Preview effects before signing
5. **Rate Limiting**: Prevent spam and abuse

## Backwards Compatibility

This standard maintains compatibility with:
- EIP-1193 for C-Chain operations
- Existing Avalanche wallet standards
- MetaMask's provider API where applicable

Migration path:
1. Wallets implement new interface alongside existing
2. dApps detect and prefer new interface
3. Deprecation period for old interfaces

## Test Cases

### Connection Test
```typescript
async function testConnection() {
  const provider = window.lux;
  assert(provider.isLux === true);
  
  const info = await provider.connect();
  assert(info.accounts.length > 0);
  assert(['P', 'X', 'C', 'M', 'Z'].includes(info.chainId));
  
  const isConnected = provider.isConnected();
  assert(isConnected === true);
}
```

### Multi-Chain Test
```typescript
async function testMultiChain() {
  const provider = window.lux;
  
  // Switch to X-Chain
  await provider.switchChain('X');
  const chainInfo = await provider.getCurrentChain();
  assert(chainInfo.chainId === 'X');
  
  // Get X-Chain specific balance
  const balance = await provider.getAssetBalance(
    'X-lux1abc...', 
    'AVAX'
  );
  assert(balance >= 0n);
}
```

### Cross-Chain Transfer Test
```typescript
async function testCrossChain() {
  const provider = window.lux as MultiChainProvider;
  
  const txId = await provider.transferCrossChain({
    asset: 'AVAX',
    amount: 1000000000n, // 1 AVAX
    sourceChain: 'X',
    destinationChain: 'C'
  });
  
  assert(typeof txId === 'string');
}
```

## Reference Implementation

Reference implementations available at:
- https://github.com/luxdefi/wallet (main wallet)
- https://github.com/luxdefi/extension (browser extension)
- https://github.com/luxdefi/wallet-sdk (SDK implementation)

Key features:
- Full multi-chain support
- Hardware wallet integration
- WalletConnect compatibility
- Mobile and desktop support

## Security Considerations

### Phishing Protection
- Display origin clearly in connection prompts
- Warn on suspicious domains
- Maintain allowlist of verified dApps

### Transaction Security
- Clear value display in native units
- Simulation results before signing
- Warning on high-value transactions
- Rate limiting on operations

### Key Management
- Never expose private keys via API
- Use hardware wallets when available
- Support for multi-sig operations
- Quantum-safe options for Z-Chain

### Privacy
- Don't leak addresses without consent
- Optional privacy mode
- Clear data on disconnect
- Respect user tracking preferences

## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).