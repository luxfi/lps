---
lip: 50
title: JavaScript SDK Specification
description: Defines the standard JavaScript/TypeScript SDK interface for Lux Network development
author: Lux Network Team (@luxdefi)
discussions-to: https://forum.lux.network/lip-50
status: Draft
type: Standards Track
category: Interface
created: 2025-01-23
requires: 1, 20, 40
---

## Abstract

This LIP specifies the standard JavaScript/TypeScript SDK interface for Lux Network development, providing a unified API for interacting with all Lux chains, smart contracts, and services. The SDK ensures consistent developer experience across applications while supporting the full feature set of the Lux ecosystem.

## Motivation

Multiple JavaScript SDKs and tools exist in the Lux ecosystem (sdk, kit, js repos) but lack standardization, leading to:

1. **Fragmented Developer Experience**: Different APIs for similar functionality
2. **Incomplete Coverage**: Some chains or features lack SDK support
3. **Maintenance Burden**: Multiple codebases implementing similar features
4. **Learning Curve**: Developers must learn multiple libraries
5. **Integration Complexity**: Difficult to use multiple Lux features together

## Specification

### Core SDK Architecture

```typescript
// Main SDK entry point
class LuxSDK {
  // Network configuration
  constructor(config: SDKConfig);
  
  // Chain-specific interfaces
  readonly pChain: PChainAPI;
  readonly xChain: XChainAPI;
  readonly cChain: CChainAPI;
  readonly mChain: MChainAPI;
  readonly zChain: ZChainAPI;
  
  // Cross-chain operations
  readonly crossChain: CrossChainAPI;
  
  // Utilities
  readonly utils: UtilityAPI;
  readonly crypto: CryptoAPI;
  
  // Provider management
  setProvider(provider: Provider): void;
  getProvider(): Provider;
  
  // Network management
  getNetwork(): NetworkInfo;
  setNetwork(network: Network | string): Promise<void>;
}

interface SDKConfig {
  network: Network | string;  // 'mainnet' | 'testnet' | 'local' | custom
  providers?: {
    p?: string | Provider;
    x?: string | Provider;
    c?: string | Provider;
    m?: string | Provider;
    z?: string | Provider;
  };
  options?: SDKOptions;
}

interface SDKOptions {
  debug?: boolean;
  timeout?: number;
  retries?: number;
  cache?: CacheConfig;
  plugins?: Plugin[];
}
```

### Chain-Specific APIs

#### P-Chain API
```typescript
interface PChainAPI {
  // Validator operations
  validators: {
    getValidators(options?: GetValidatorsOptions): Promise<Validator[]>;
    getValidator(nodeID: string): Promise<Validator>;
    addValidator(params: AddValidatorParams): Promise<Transaction>;
    addDelegator(params: AddDelegatorParams): Promise<Transaction>;
  };
  
  // Subnet operations
  subnets: {
    getSubnets(): Promise<Subnet[]>;
    getSubnet(subnetID: string): Promise<Subnet>;
    createSubnet(params: CreateSubnetParams): Promise<Transaction>;
    addSubnetValidator(params: AddSubnetValidatorParams): Promise<Transaction>;
  };
  
  // Staking operations
  staking: {
    getStake(address: string): Promise<StakeInfo>;
    getRewards(address: string): Promise<RewardInfo>;
    claimRewards(address: string): Promise<Transaction>;
  };
  
  // Chain operations
  getCurrentHeight(): Promise<number>;
  getBlock(height: number | string): Promise<Block>;
  getTransaction(txID: string): Promise<Transaction>;
}
```

#### X-Chain API
```typescript
interface XChainAPI {
  // Asset operations
  assets: {
    getAssets(): Promise<Asset[]>;
    getAsset(assetID: string): Promise<Asset>;
    createAsset(params: CreateAssetParams): Promise<Transaction>;
    mint(params: MintParams): Promise<Transaction>;
  };
  
  // Trading operations (LX Exchange)
  exchange: {
    getMarkets(): Promise<Market[]>;
    getOrderBook(market: string): Promise<OrderBook>;
    placeOrder(params: OrderParams): Promise<Order>;
    cancelOrder(orderID: string): Promise<void>;
    getOrders(address?: string): Promise<Order[]>;
    getTrades(market: string, limit?: number): Promise<Trade[]>;
  };
  
  // UTXO operations
  utxos: {
    getUTXOs(address: string, assetID?: string): Promise<UTXO[]>;
    getBalance(address: string, assetID?: string): Promise<Balance>;
  };
  
  // Transaction building
  buildTransaction(params: XChainTxParams): Promise<UnsignedTransaction>;
  send(params: SendParams): Promise<Transaction>;
}
```

#### C-Chain API (EVM)
```typescript
interface CChainAPI {
  // Contract operations
  contracts: {
    deploy(params: DeployParams): Promise<Contract>;
    at(address: string, abi: ABI): Contract;
    getCode(address: string): Promise<string>;
    estimateGas(tx: TransactionRequest): Promise<bigint>;
  };
  
  // Token operations (LRC-20)
  tokens: {
    getLRC20(address: string): LRC20Token;
    getLRC721(address: string): LRC721Token;
    getLRC1155(address: string): LRC1155Token;
    deployLRC20(params: LRC20DeployParams): Promise<LRC20Token>;
  };
  
  // DeFi operations
  defi: {
    getLiquidityPool(address: string): LiquidityPool;
    getRouter(address: string): Router;
    swap(params: SwapParams): Promise<Transaction>;
    addLiquidity(params: LiquidityParams): Promise<Transaction>;
  };
  
  // Standard Web3 operations
  getBalance(address: string): Promise<bigint>;
  getTransactionCount(address: string): Promise<number>;
  call(tx: TransactionRequest): Promise<string>;
  sendTransaction(tx: TransactionRequest): Promise<Transaction>;
}
```

#### M-Chain API (Bridge)
```typescript
interface MChainAPI {
  // Bridge operations
  bridge: {
    getSupportedAssets(): Promise<BridgeAsset[]>;
    getBridgeFee(params: BridgeFeeParams): Promise<BridgeFee>;
    initiateTransfer(params: BridgeTransferParams): Promise<BridgeTransaction>;
    getTransferStatus(bridgeID: string): Promise<BridgeStatus>;
    claimTransfer(bridgeID: string): Promise<Transaction>;
  };
  
  // MPC operations
  mpc: {
    getValidators(): Promise<MPCValidator[]>;
    getThreshold(): Promise<ThresholdInfo>;
    getSignatures(messageHash: string): Promise<Signature[]>;
  };
  
  // Asset registry
  assets: {
    getRegisteredAssets(): Promise<RegisteredAsset[]>;
    registerAsset(params: RegisterAssetParams): Promise<Transaction>;
    getAssetMapping(chain: string, assetID: string): Promise<AssetMapping>;
  };
}
```

#### Z-Chain API (Privacy)
```typescript
interface ZChainAPI {
  // Privacy operations
  privacy: {
    generateStealthAddress(): StealthAddress;
    shieldAssets(params: ShieldParams): Promise<PrivateTransaction>;
    unshieldAssets(params: UnshieldParams): Promise<Transaction>;
    privateTransfer(params: PrivateTransferParams): Promise<PrivateTransaction>;
  };
  
  // Zero-knowledge proofs
  zk: {
    generateProof(params: ProofParams): Promise<Proof>;
    verifyProof(proof: Proof): Promise<boolean>;
    getProvingKey(circuit: string): Promise<ProvingKey>;
  };
  
  // Attestations
  attestations: {
    createAttestation(params: AttestationParams): Promise<Attestation>;
    verifyAttestation(attestation: Attestation): Promise<boolean>;
    getAttestations(subject: string): Promise<Attestation[]>;
  };
}
```

### Cross-Chain Operations

```typescript
interface CrossChainAPI {
  // Asset transfers
  transfer(params: {
    asset: string;
    amount: bigint;
    from: ChainLocation;
    to: ChainLocation;
    recipient?: string;
  }): Promise<CrossChainTransaction>;
  
  // Import/Export
  importAsset(params: ImportParams): Promise<Transaction>;
  exportAsset(params: ExportParams): Promise<Transaction>;
  
  // Atomic swaps
  createAtomicSwap(params: AtomicSwapParams): Promise<AtomicSwap>;
  executeAtomicSwap(swapID: string, secret: string): Promise<Transaction>;
  refundAtomicSwap(swapID: string): Promise<Transaction>;
  
  // Multi-chain queries
  getBalances(address: string): Promise<MultiChainBalance>;
  getTransactionHistory(address: string): Promise<CrossChainTransaction[]>;
}
```

### Utility APIs

```typescript
interface UtilityAPI {
  // Address utilities
  addresses: {
    parse(address: string): AddressInfo;
    format(address: string, chain: string): string;
    validate(address: string, chain?: string): boolean;
    derive(mnemonic: string, path: string): KeyPair;
  };
  
  // Formatting utilities
  format: {
    formatLUX(value: bigint): string;
    parseLUX(value: string): bigint;
    formatAsset(value: bigint, decimals: number): string;
    parseAsset(value: string, decimals: number): bigint;
  };
  
  // Time utilities
  time: {
    getCurrentTime(): Promise<number>;
    getBlockTime(chain: string): Promise<number>;
    convertTime(time: number, from: string, to: string): number;
  };
}

interface CryptoAPI {
  // Key management
  keys: {
    generateMnemonic(strength?: number): string;
    generateKeyPair(): KeyPair;
    deriveKeyPair(mnemonic: string, path: string): KeyPair;
    sign(message: Uint8Array, privateKey: PrivateKey): Signature;
    verify(message: Uint8Array, signature: Signature, publicKey: PublicKey): boolean;
  };
  
  // Hashing
  hash: {
    sha256(data: Uint8Array): Uint8Array;
    keccak256(data: Uint8Array): Uint8Array;
    ripemd160(data: Uint8Array): Uint8Array;
  };
  
  // Encoding
  encode: {
    cb58(data: Uint8Array): string;
    hex(data: Uint8Array): string;
    base64(data: Uint8Array): string;
  };
  
  decode: {
    cb58(data: string): Uint8Array;
    hex(data: string): Uint8Array;
    base64(data: string): Uint8Array;
  };
}
```

### Smart Contract Interaction

```typescript
class Contract {
  constructor(address: string, abi: ABI, chainAPI: CChainAPI);
  
  // Dynamic method generation based on ABI
  [methodName: string]: ContractMethod;
  
  // Event handling
  on(event: string, callback: EventCallback): void;
  once(event: string, callback: EventCallback): void;
  off(event: string, callback?: EventCallback): void;
  
  // Query past events
  queryEvents(event: string, options?: EventQueryOptions): Promise<Event[]>;
  
  // Contract info
  address: string;
  interface: Interface;
  provider: Provider;
}

interface ContractMethod {
  // Call (read-only)
  (...args: any[]): Promise<any>;
  
  // Send transaction
  send(...args: any[]): Promise<Transaction>;
  
  // Estimate gas
  estimateGas(...args: any[]): Promise<bigint>;
  
  // Encode call data
  encode(...args: any[]): string;
}
```

### Event System

```typescript
interface SDKEvents {
  // Network events
  'network:changed': (network: NetworkInfo) => void;
  'network:connected': (network: NetworkInfo) => void;
  'network:disconnected': (error?: Error) => void;
  
  // Transaction events
  'transaction:sent': (tx: Transaction) => void;
  'transaction:confirmed': (tx: Transaction) => void;
  'transaction:failed': (tx: Transaction, error: Error) => void;
  
  // Block events
  'block:new': (block: Block) => void;
  
  // Custom events
  [event: string]: (...args: any[]) => void;
}

// SDK extends EventEmitter
interface LuxSDK extends EventEmitter<SDKEvents> {
  // ... rest of SDK interface
}
```

### Error Handling

```typescript
class LuxSDKError extends Error {
  code: ErrorCode;
  chain?: string;
  details?: any;
}

enum ErrorCode {
  // Network errors
  NETWORK_ERROR = 'NETWORK_ERROR',
  TIMEOUT = 'TIMEOUT',
  
  // Transaction errors
  INSUFFICIENT_FUNDS = 'INSUFFICIENT_FUNDS',
  INVALID_TRANSACTION = 'INVALID_TRANSACTION',
  TRANSACTION_FAILED = 'TRANSACTION_FAILED',
  
  // Validation errors
  INVALID_ADDRESS = 'INVALID_ADDRESS',
  INVALID_AMOUNT = 'INVALID_AMOUNT',
  INVALID_ASSET = 'INVALID_ASSET',
  
  // Chain-specific
  CHAIN_NOT_SUPPORTED = 'CHAIN_NOT_SUPPORTED',
  FEATURE_NOT_SUPPORTED = 'FEATURE_NOT_SUPPORTED'
}
```

### Plugin System

```typescript
interface Plugin {
  name: string;
  version: string;
  install(sdk: LuxSDK): void | Promise<void>;
}

// Example plugin
class MetricsPlugin implements Plugin {
  name = 'metrics';
  version = '1.0.0';
  
  install(sdk: LuxSDK) {
    sdk.on('transaction:sent', (tx) => {
      // Track transaction metrics
    });
  }
}
```

## Rationale

### Design Decisions

1. **Unified Interface**: Single SDK instance provides access to all chains
2. **Chain Separation**: Clear separation between chain-specific and cross-chain operations
3. **Type Safety**: Full TypeScript support with comprehensive types
4. **Extensibility**: Plugin system for custom functionality
5. **Async-First**: All network operations return Promises

### Architecture Choices

1. **Modular Design**: Each chain API can be used independently
2. **Provider Abstraction**: Works with different provider implementations
3. **Event-Driven**: Reactive programming model for real-time updates
4. **Error Recovery**: Built-in retry logic and error handling

## Backwards Compatibility

The SDK maintains compatibility with:
- Existing AvalancheJS library patterns
- Web3.js/Ethers.js for C-Chain operations
- Standard JSON-RPC interfaces

Migration strategy:
1. Implement wrapper for legacy APIs
2. Deprecation warnings for old methods
3. Migration guide and tooling

## Test Cases

### Basic Usage Test
```typescript
import { LuxSDK } from '@luxdefi/sdk';

async function testBasicUsage() {
  // Initialize SDK
  const sdk = new LuxSDK({
    network: 'testnet'
  });
  
  // Get balance across chains
  const balances = await sdk.crossChain.getBalances('lux1...');
  assert(balances.P >= 0n);
  assert(balances.X >= 0n);
  assert(balances.C >= 0n);
}
```

### Contract Interaction Test
```typescript
async function testContract() {
  const sdk = new LuxSDK({ network: 'mainnet' });
  
  // Get LRC-20 token
  const token = sdk.cChain.tokens.getLRC20('0x...');
  
  // Read balance
  const balance = await token.balanceOf('0x...');
  assert(balance >= 0n);
  
  // Transfer tokens
  const tx = await token.transfer('0x...', parseUnits('100', 18)).send();
  assert(tx.hash);
  
  // Wait for confirmation
  await tx.wait();
}
```

### Cross-Chain Test
```typescript
async function testCrossChain() {
  const sdk = new LuxSDK({ network: 'testnet' });
  
  // Transfer AVAX from X to C chain
  const crossTx = await sdk.crossChain.transfer({
    asset: 'AVAX',
    amount: parseUnits('10', 9),
    from: { chain: 'X', address: 'X-lux1...' },
    to: { chain: 'C', address: '0x...' }
  });
  
  // Monitor status
  sdk.on('transaction:confirmed', (tx) => {
    console.log('Transfer completed:', tx.hash);
  });
}
```

## Reference Implementation

Reference implementation at: https://github.com/luxdefi/sdk

Key packages:
- `@luxdefi/sdk`: Main SDK package
- `@luxdefi/sdk-utils`: Standalone utilities
- `@luxdefi/sdk-types`: TypeScript type definitions
- `@luxdefi/sdk-plugins`: Official plugins

## Security Considerations

### Key Management
- SDK never stores private keys
- Support for hardware wallet signing
- Clear separation of signing and broadcasting

### Input Validation
- Validate all addresses before use
- Check amounts don't exceed balances
- Verify contract addresses against registry

### Network Security
- Use HTTPS endpoints only
- Validate SSL certificates
- Implement request signing for sensitive operations

### Error Handling
- Never expose sensitive data in errors
- Rate limiting on all operations
- Circuit breakers for failing endpoints

## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).