---
lip: 11
title: X-Chain (Exchange Chain) Specification
description: Defines the high-performance Exchange Chain for asset transfers and trading
author: Lux Network Team (@luxdefi)
discussions-to: https://forum.lux.network/lip-11
status: Draft
type: Standards Track
category: Core
created: 2025-01-22
updated: 2025-01-23
requires: 0, 3, 4
---  

## Abstract

This LIP specifies the X-Chain Exchange Protocol, a high-performance on-chain order book exchange built on Lux's X-Chain. The protocol combines LX L1's cancel-first ordering, dYdX v4's risk engine, and Lux's native cross-chain capabilities to deliver sub-200ms latency trading with full transparency.

## Motivation

Current DEX architectures face a trilemma between speed, transparency, and composability:
- AMMs suffer from impermanent loss and poor capital efficiency
- Off-chain order books sacrifice transparency for speed
- Hybrid models introduce trust assumptions

X-Chain Exchange resolves this by implementing a fully on-chain CLOB with CeFi-grade performance.

## Specification

### 1. Core Architecture

```
┌────────────────────┐                ┌─────────────────────┐
│  Front-end / SDK   │  ← gRPC/WS →   │   Aggregator Node   │
└────────┬───────────┘                └─────────┬───────────┘
         │ OrderTx, CancelTx, OracleTx          │ packs mempool → BlockProposal
         ▼                                      ▼
┌──────────────────────────────────────────────────────────────┐
│                  X-Chain Consensus (Lux-Snowman)             │
│  • Deterministic ordering module (cancel-first)              │
│  • Execution Engine (CLOB + Risk)                            │
│  • Emits xRoot                                               │
└────────┬───────────────────────────┬─────────────────────────┘
         │ WarpMsg(funding, pnl)     │ RootUpdate(xRoot)
         ▼                           ▼
   C-Chain / Warp                Yggdrasil (Z-Chain)      Hanzo GPU
                                                         (risk off-load)
```

### 2. Transaction Types and Ordering

#### 2.1 Transaction Types

| OpCode | Payload Fields | Gas | Description |
|--------|---------------|-----|-------------|
| ORDER_NEW | `{marketID, side, price, size, type(GTC/IOC/POST)}` | 1400 | Inserts into book |
| ORDER_CANCEL | `{orderID}` | 500 | Cancels; priority rank 0 |
| ORDER_MODIFY | `{orderID, newPrice, newSize}` | 1200 | Shortcut = CANCEL+NEW |
| ORACLE_COMMIT | `{marketID, price, twap, sig}` | 50000 | Whitelisted feeders only |
| LIQUIDATE_BATCH | `{traderAddrs[], keeper}` | 250 + 130/trader | 40% gas rebate to keeper |
| CROSS_MARGIN_DEPOSIT | `{asset, amount}` | 19000 | Teleported asset credit |
| CROSS_MARGIN_WITHDRAW | `{asset, amount}` | 22000 | Warp to C-Chain/Z-Chain |

#### 2.2 Canonical Ordering

Transactions MUST be sorted by priority, then by nonce:

```
P0: ORDER_CANCEL  
P1: ORDER_NEW (POST-ONLY)  
P2: ORDER_NEW (GTC/IOC) & MODIFY  
P3: ORACLE & LIQUIDATE_BATCH
```

### 3. State Model

```go
// Core state structures
type OrderBook struct {
    MarketID    uint32
    BidLevels   *RBTree  // price -> OrderLevel
    AskLevels   *RBTree  // price -> OrderLevel
    LastTradeID uint64
}

type Trader struct {
    Account   MarginAccount
    Positions map[uint32]*Position  // marketID -> position
    Orders    map[uint64]*Order     // orderID -> order
}

type MarginAccount struct {
    TotalDeposits uint128  // in xLUX units
    TotalBorrows  uint128
    HealthGroup   uint32   // bucket for O(1) liquidation scan
    Nonce         uint64
}

type Position struct {
    Size         int128   // positive=long, negative=short
    EntryPrice   uint64   // volume-weighted average
    FundingIndex uint64   // last funding payment index
    MarketID     uint32
}
```

### 4. Execution Engine

#### 4.1 Block Execution Algorithm

```go
func ExecuteBlock(block *Block) {
    // Phase 1: Sort transactions by canonical order
    txs := CanonicalSort(block.Transactions)
    
    // Phase 2: Execute in order
    for _, tx := range txs {
        switch tx.Type {
        case ORDER_CANCEL:
            engine.CancelOrder(tx.OrderID)
        case ORDER_NEW:
            engine.PlaceOrder(tx.Order)
        case ORDER_MODIFY:
            engine.ModifyOrder(tx.OrderID, tx.NewPrice, tx.NewSize)
        case ORACLE_COMMIT:
            engine.UpdateOracle(tx.MarketID, tx.Price)
        }
    }
    
    // Phase 3: Run matching engine
    engine.RunMatching()
    
    // Phase 4: Post-block processing
    riskVector := Hanzo.ComputeRisk()  // GPU batch
    engine.LiquidateBadAccounts(riskVector)
    engine.ComputeFunding()
    
    // Phase 5: Emit root
    xRoot := ComputeRoot(orderRoots, accountRoot, fundingAccruals)
    EmitRootUpdate(xRoot)
}
```

#### 4.2 Matching Algorithm

```go
func (e *Engine) RunMatching() {
    for _, book := range e.Books {
        for book.HasMatch() {
            bestBid := book.BestBid()
            bestAsk := book.BestAsk()
            
            if bestBid.Price >= bestAsk.Price {
                // Match at passive order price
                price := bestAsk.Price
                if bestBid.Time < bestAsk.Time {
                    price = bestBid.Price
                }
                
                size := min(bestBid.Size, bestAsk.Size)
                e.ExecuteTrade(bestBid, bestAsk, price, size)
            }
        }
    }
}
```

### 5. Risk Engine

#### 5.1 Health Computation

```go
type RiskParams struct {
    Assets map[string]AssetRisk
}

type AssetRisk struct {
    InitialMargin      Decimal  // 0.05 = 5%
    MaintenanceMargin  Decimal  // 0.025 = 2.5%
    MaxLeverage        uint8    // 20x max
}

func ComputeHealth(account *MarginAccount, positions []*Position) Decimal {
    equity := account.TotalDeposits - account.TotalBorrows
    
    for _, pos := range positions {
        markPrice := GetMarkPrice(pos.MarketID)
        pnl := (markPrice - pos.EntryPrice) * pos.Size
        equity += pnl
    }
    
    marginRequired := ComputeMarginRequired(positions)
    return equity / marginRequired
}
```

#### 5.2 GPU Acceleration (Hanzo)

```cuda
__global__ void computeHealthBatch(
    Account* accounts,
    Position* positions,
    float* markPrices,
    float* healthScores,
    int numAccounts
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx >= numAccounts) return;
    
    Account acc = accounts[idx];
    float equity = acc.deposits - acc.borrows;
    
    // Compute PnL across all positions
    for (int i = acc.posStart; i < acc.posEnd; i++) {
        Position pos = positions[i];
        float pnl = (markPrices[pos.marketId] - pos.entry) * pos.size;
        equity += pnl;
    }
    
    healthScores[idx] = equity / acc.marginRequired;
}
```

### 6. Fee Model

| Actor | Fee Source | Rebate/Reward |
|-------|-----------|---------------|
| Makers | -2 bp rebate | Paid from taker fees |
| Takers | 2 bp fee | Standard |
| Validators | 25% of net fees | Distributed per block |
| Liquidation Keepers | 5% of seized collateral | Paid instantly |
| Hanzo GPU Provers | 0.4 LUX per batch | Auto-withdraw via Warp |

Gas rebate: 100% refund up to 5k gas to encourage tight trading loops.

### 7. API Specification

#### 7.1 gRPC Order Gateway

```protobuf
service XOrder {
    rpc NewOrder(NewOrderReq) returns (OrderAck);
    rpc Cancel(CancelReq) returns (CancelAck);
    rpc Modify(ModifyReq) returns (ModifyAck);
    rpc BookStream(BookSub) returns (stream BookDelta);
    rpc TradeStream(TradeSub) returns (stream TradeEvent);
}

message NewOrderReq {
    uint32 market_id = 1;
    enum Side { BUY = 0; SELL = 1; }
    Side side = 2;
    uint64 price = 3;      // 6 decimals
    uint64 size = 4;       // 8 decimals
    enum Type { GTC = 0; IOC = 1; POST = 2; }
    Type type = 5;
}
```

#### 7.2 WebSocket Feed

```javascript
// Connect
ws://localhost:7001/ws?streams=book.BTC-PERP@100ms/trades.BTC-PERP

// Book update
{
    "stream": "book.BTC-PERP@100ms",
    "data": {
        "bids": [[68000.00, 12.5], [67999.50, 8.2]],
        "asks": [[68000.50, 10.1], [68001.00, 15.3]],
        "timestamp": 1737562800123
    }
}
```

### 8. Performance Targets

| Metric | Target | Method |
|--------|--------|--------|
| Block Time | 1s | Standard Snowman++ |
| Soft Finality | 200ms | Proposal broadcast |
| Hard Finality | 1s | Certificate |
| Throughput | 100k orders/sec | Measured on testnet |
| End-to-end Latency | 150-200ms | WebSocket push |
| Risk Computation | 8ms per 100k accounts | Hanzo GPU |

### 9. Cross-Chain Integration

#### 9.1 Teleport Protocol Integration

```go
// Deposit from external chain
func (e *Engine) ProcessTeleportDeposit(
    asset string,
    amount uint128,
    trader address,
    proof TeleportProof,
) error {
    // Verify MPC signatures
    if !e.mpcManager.VerifyTeleportProof(proof) {
        return ErrInvalidProof
    }
    
    // Credit account
    account := e.GetOrCreateAccount(trader)
    account.TotalDeposits += amount
    
    return nil
}
```

#### 9.2 NFT Trading Support

```go
// NFT spot markets
type NFTOrder struct {
    Collection address
    TokenID    uint256
    Price      uint128
    Expiry     uint64
}
```

### 10. Security Considerations

#### 10.1 MEV Protection
- Cancel-first ordering prevents front-running
- Post-only orders execute before market orders
- Block builders must follow canonical ordering or face rejection

#### 10.2 Oracle Security
- Requires 2+ independent price feeds
- Deviation > 0.1% triggers circuit breaker
- TWAP window prevents flash loan attacks

#### 10.3 Risk Limits
- Per-account order limit: 10,000 open orders
- Position limits based on market liquidity
- Auto-deleveraging in extreme scenarios

## Rationale

The design choices optimize for:

1. **Performance**: GPU-accelerated risk computation, pipelined consensus
2. **Fairness**: Deterministic cancel-first ordering
3. **Composability**: Native cross-chain settlement via Teleport
4. **Transparency**: Every action recorded on-chain

## Implementation

Reference implementation: `github.com/luxfi/node/xvm/exchange`

Key modules:
- `orderbook/`: CLOB implementation
- `risk/`: Risk engine and GPU kernels
- `matching/`: Deterministic matching engine
- `api/`: gRPC and WebSocket servers

## Timeline

| Milestone | Date | Features |
|-----------|------|----------|
| α-Testnet | Aug 2025 | Single market, no GPU |
| β-Testnet | Oct 2025 | 20 pairs, GPU risk, Yggdrasil anchoring |
| Mainnet Phase 1 | Jan 2026 | 50+ perps, cross-margin, gas rebates |
| Mainnet Phase 2 | Mar 2026 | FHE auctions, Z-Chain privacy |

## Copyright

Copyright and related rights waived via CC0.