---
lip: 3
title: LX Exchange Protocol
description: Defines the high-performance on-chain exchange protocol for Lux Network X-Chain
author: Lux Network Team (@luxdefi)
discussions-to: https://forum.lux.network/lip-3
status: Draft
type: Standards Track
category: Core
created: 2025-01-23
requires: 1, 2, 11
---

## Abstract

This LIP specifies the LX Exchange Protocol, a high-performance on-chain central limit order book (CLOB) exchange built on the Lux Network X-Chain. The protocol enables sub-200ms latency trading with institutional-grade features including advanced order types, cross-margin, portfolio margining, and GPU-accelerated risk management.

## Motivation

Decentralized exchanges have historically suffered from poor performance and limited features compared to centralized exchanges. The LX Exchange Protocol addresses these limitations by:

1. **Performance**: Achieving CEX-like latency (<200ms) while remaining fully on-chain
2. **Features**: Supporting advanced order types and risk management
3. **Capital Efficiency**: Enabling cross-margin and portfolio margining
4. **Composability**: Integrating seamlessly with DeFi protocols
5. **Fairness**: Implementing cancel-first ordering to prevent adverse selection

## Specification

### Core Architecture

```
┌─────────────────────────────────────────────────┐
│              LX Exchange Protocol                │
├─────────────────────────────────────────────────┤
│                 Order Gateway                    │
│         (Cancel-First Order Processing)          │
├─────────────────────────────────────────────────┤
│              Matching Engine                     │
│         (GPU-Accelerated via Hanzo)              │
├─────────────────────────────────────────────────┤
│               Risk Engine                        │
│        (Real-time Portfolio Margining)           │
├─────────────────────────────────────────────────┤
│              Settlement Layer                    │
│         (X-Chain Native Settlement)              │
└─────────────────────────────────────────────────┘
```

### Order Types - FIX 4.4 Aligned

#### Basic Orders (FIX Tag 40 = OrdType)
```solidity
enum OrderType {
    MARKET,           // 1 = Market order
    LIMIT,            // 2 = Limit order
    STOP,             // 3 = Stop order
    STOP_LIMIT,       // 4 = Stop limit order
    PEGGED            // P = Pegged order
}

enum Side {           // FIX Tag 54
    BUY,              // 1 = Buy
    SELL              // 2 = Sell (Ask in FIX)
}

enum TimeInForce {    // FIX Tag 59
    GTC,              // 0 = Good Till Cancel (Day in FIX)
    GTD,              // 6 = Good Till Date
    IOC,              // 3 = Immediate or Cancel
    FOK,              // 4 = Fill or Kill
    POST_ONLY         // ExecInst(18) = P (Post-Only)
}

struct Order {
    bytes32 orderId;           // FIX Tag 37 = OrderID (engine-assigned)
    bytes32 clientOrderId;     // FIX Tag 11 = ClOrdID (client-assigned)
    address trader;
    string symbol;             // FIX Tag 55 = Symbol (e.g., "BTCUSDC", "LUXUSDC")
    OrderType orderType;       // FIX Tag 40 = OrdType
    Side side;                 // FIX Tag 54 = Side
    uint256 price;             // FIX Tag 44 = Price (in micro-units, 1e-6)
    uint256 orderQty;          // FIX Tag 38 = OrderQty (base asset, 1e-6)
    uint256 cashOrderQty;      // FIX Tag 152 = CashOrderQty (notional USD)
    uint256 stopPx;            // FIX Tag 99 = StopPx (trigger price)
    TimeInForce timeInForce;   // FIX Tag 59 = TimeInForce
    string execInst;           // FIX Tag 18 = ExecInst (P=PostOnly, R=ReduceOnly)
    uint256 expireTime;        // FIX Tag 126 = ExpireTime (for GTD)
    uint256 leverage;          // Custom field for derivatives
    uint256 margin;            // Custom field for margin trading
    uint256 transactTime;      // FIX Tag 60 = TransactTime
}
```

#### Advanced Orders
```solidity
struct ConditionalOrder {
    Order baseOrder;
    string triggerSymbol;      // FIX Tag 55 for trigger market
    uint256 triggerPrice;      // Trigger price condition
    TriggerType triggerType;   // MARK, INDEX, or LAST
    char positionEffect;       // FIX Tag 77: O=Open, C=Close
}

struct BracketOrder {
    Order entryOrder;
    Order takeProfitOrder;
    Order stopLossOrder;
    string contingencyType;    // FIX Tag 1385: 1=OCO, 2=OTO
}

// Execution Report - FIX MsgType 35=8
struct ExecutionReport {
    bytes32 orderId;           // FIX Tag 37 = OrderID
    bytes32 clientOrderId;     // FIX Tag 11 = ClOrdID
    bytes32 execId;            // FIX Tag 17 = ExecID
    char execType;             // FIX Tag 150 = ExecType
    char ordStatus;            // FIX Tag 39 = OrdStatus
    string symbol;             // FIX Tag 55 = Symbol
    Side side;                 // FIX Tag 54 = Side
    uint256 orderQty;          // FIX Tag 38 = OrderQty
    uint256 price;             // FIX Tag 44 = Price
    uint256 lastPx;            // FIX Tag 31 = LastPx (fill price)
    uint256 lastQty;           // FIX Tag 32 = LastQty (fill quantity)
    uint256 leavesQty;         // FIX Tag 151 = LeavesQty (remaining)
    uint256 cumQty;            // FIX Tag 14 = CumQty (total filled)
    uint256 avgPx;             // FIX Tag 6 = AvgPx (VWAP)
    uint256 transactTime;      // FIX Tag 60 = TransactTime
    string text;               // FIX Tag 58 = Text (reject reason)
}

// FIX Tag Enumerations
enum ExecType {               // FIX Tag 150
    NEW = '0',                // New order accepted
    PARTIAL_FILL = '1',       // Partial fill
    FILL = '2',               // Full fill
    DONE_FOR_DAY = '3',       // Order done for day
    CANCELED = '4',           // Order canceled
    REPLACED = '5',           // Order replaced
    PENDING_CANCEL = '6',     // Cancel request pending
    STOPPED = '7',            // Order stopped
    REJECTED = '8',           // Order rejected
    SUSPENDED = '9',          // Order suspended
    PENDING_NEW = 'A',        // New order pending
    CALCULATED = 'B',         // Order calculated
    EXPIRED = 'C',            // Order expired
    RESTATED = 'D',           // Order restated
    PENDING_REPLACE = 'E',    // Replace request pending
    TRADE = 'F'               // Trade execution
}

enum OrdStatus {              // FIX Tag 39
    NEW = '0',                // New order
    PARTIALLY_FILLED = '1',   // Partially filled
    FILLED = '2',             // Completely filled
    DONE_FOR_DAY = '3',       // Done for day
    CANCELED = '4',           // Canceled
    PENDING_CANCEL = '6',     // Pending cancel
    STOPPED = '7',            // Stopped
    REJECTED = '8',           // Rejected
    SUSPENDED = '9',          // Suspended
    PENDING_NEW = 'A',        // Pending new
    CALCULATED = 'B',         // Calculated
    EXPIRED = 'C',            // Expired
    ACCEPTED_FOR_BIDDING = 'D', // Accepted for bidding
    PENDING_REPLACE = 'E'     // Pending replace
}
```

### Market Structure

```solidity
struct Market {
    bytes32 marketId;          // e.g., "BTC-PERP"
    address baseAsset;         // Base asset address
    address quoteAsset;        // Quote asset (usually USD)
    uint256 tickSize;          // Minimum price increment
    uint256 lotSize;           // Minimum size increment
    uint256 makerFee;          // Maker fee (negative = rebate)
    uint256 takerFee;          // Taker fee
    uint256 maxLeverage;       // Maximum allowed leverage
    uint256 maintenanceMargin; // Maintenance margin ratio
    uint256 initialMargin;     // Initial margin ratio
    bool isActive;             // Market active status
}
```

### Cancel-First Ordering

The protocol implements cancel-first ordering to protect market makers:

```python
def process_batch(messages):
    # Phase 1: Process all cancellations
    for msg in messages:
        if msg.type == CANCEL:
            cancel_order(msg.orderId)
    
    # Phase 2: Process new orders
    for msg in messages:
        if msg.type == NEW_ORDER:
            validate_and_insert(msg.order)
    
    # Phase 3: Run matching
    run_matching_engine()
```

### Matching Engine

#### Price-Time Priority
```python
class OrderBook:
    def match_order(self, incoming_order):
        if incoming_order.side == BUY:
            # Match against asks (lowest price first, then time)
            for ask in self.asks.ascending():
                if incoming_order.price >= ask.price:
                    fill_size = min(incoming_order.remaining, ask.remaining)
                    execute_trade(incoming_order, ask, fill_size)
        else:
            # Match against bids (highest price first, then time)
            for bid in self.bids.descending():
                if incoming_order.price <= bid.price:
                    fill_size = min(incoming_order.remaining, bid.remaining)
                    execute_trade(incoming_order, bid, fill_size)
```

### Risk Management

#### Portfolio Margining
```solidity
function calculatePortfolioMargin(address trader) view returns (uint256) {
    Position[] memory positions = getPositions(trader);
    
    // Calculate cross-market risk
    uint256 totalRisk = 0;
    for (uint i = 0; i < positions.length; i++) {
        for (uint j = i + 1; j < positions.length; j++) {
            uint256 correlation = getCorrelation(positions[i].market, positions[j].market);
            totalRisk += calculateCrossRisk(positions[i], positions[j], correlation);
        }
    }
    
    // Apply portfolio benefits
    uint256 diversificationBenefit = calculateDiversificationBenefit(positions);
    return totalRisk - diversificationBenefit;
}
```

#### Liquidation Engine
```solidity
function checkLiquidation(address trader) external {
    uint256 equity = calculateEquity(trader);
    uint256 maintenanceMargin = calculateMaintenanceMargin(trader);
    
    if (equity < maintenanceMargin) {
        // Partial liquidation to bring back to initial margin
        uint256 liquidationSize = calculateLiquidationSize(trader);
        liquidatePosition(trader, liquidationSize);
        
        // If still underwater, full liquidation
        if (calculateEquity(trader) < maintenanceMargin) {
            liquidateAllPositions(trader);
        }
    }
}
```

### Settlement

All trades settle immediately on X-Chain:

```solidity
function settleTrade(Trade memory trade) internal {
    // Transfer from taker
    transferMargin(trade.taker, trade.takerMargin);
    
    // Transfer from maker
    transferMargin(trade.maker, trade.makerMargin);
    
    // Update positions
    updatePosition(trade.taker, trade.market, trade.size, trade.price);
    updatePosition(trade.maker, trade.market, -trade.size, trade.price);
    
    // Emit events
    emit TradeExecuted(trade);
}
```

### API Specification

#### REST API
```typescript
// Place order
POST /api/v1/orders
{
    "market": "BTC-PERP",
    "side": "buy",
    "type": "limit",
    "price": "65000",
    "size": "0.5",
    "leverage": "10",
    "postOnly": true
}

// Cancel order
DELETE /api/v1/orders/{orderId}

// Get order book
GET /api/v1/markets/{marketId}/orderbook?depth=20

// Get positions
GET /api/v1/positions
```

#### WebSocket Streams
```typescript
// Order book updates
ws.subscribe({
    "channel": "orderbook",
    "market": "BTC-PERP",
    "depth": 10
});

// Trade feed
ws.subscribe({
    "channel": "trades",
    "market": "BTC-PERP"
});

// Position updates
ws.subscribe({
    "channel": "positions",
    "auth": true
});
```

### Performance Targets

| Metric | Target | Method |
|--------|--------|--------|
| Order Latency | <200ms | Direct X-Chain submission |
| Throughput | 100,000 orders/sec | GPU acceleration |
| Book Depth | 1000 levels | Optimized data structures |
| Settlement | Instant | X-Chain native |

## Rationale

### Design Decisions

1. **X-Chain Integration**: Built directly on X-Chain for maximum performance
2. **Cancel-First**: Protects market makers from adverse selection
3. **GPU Acceleration**: Leverages Hanzo for complex risk calculations
4. **Portfolio Margining**: Maximizes capital efficiency for traders
5. **Native Settlement**: No wrapped tokens or synthetic assets

### Trade-offs

1. **Centralized Matching**: Single matching engine for performance
2. **Complexity**: Advanced features increase implementation complexity
3. **Hardware Requirements**: GPU acceleration requires specialized validators

## Backwards Compatibility

The LX Exchange Protocol is designed to be compatible with:
- Existing X-Chain asset standards
- LIP-2 liquidity pools for backstop liquidity
- Standard wallet interfaces

## Test Cases

### Order Matching Tests
```python
def test_price_time_priority():
    book = OrderBook("BTC-PERP")
    
    # Add orders
    book.add_order(Order(price=65000, size=1, time=100))
    book.add_order(Order(price=65000, size=2, time=101))
    book.add_order(Order(price=64999, size=3, time=102))
    
    # Incoming market buy
    trades = book.match_order(Order(
        side=BUY,
        type=MARKET,
        size=4
    ))
    
    assert len(trades) == 2
    assert trades[0].price == 64999
    assert trades[0].size == 3
    assert trades[1].price == 65000
    assert trades[1].size == 1
```

### Risk Management Tests
```python
def test_portfolio_margin():
    trader = create_trader()
    
    # Correlated positions
    open_position(trader, "BTC-PERP", size=1, price=65000)
    open_position(trader, "ETH-PERP", size=10, price=3500)
    
    # Portfolio margin should be less than sum
    portfolio_margin = calculate_portfolio_margin(trader)
    individual_margin = calculate_margin("BTC-PERP", 1) + calculate_margin("ETH-PERP", 10)
    
    assert portfolio_margin < individual_margin * 0.8
```

## Reference Implementation

A reference implementation is available at:
https://github.com/luxdefi/lx-exchange

Key components:
- Matching engine (Rust + GPU)
- Risk engine (Go + Hanzo)
- Settlement contracts (Solidity)
- API gateway (Node.js)

## Security Considerations

### Market Manipulation
- Price bands prevent extreme moves
- Position limits prevent cornering markets
- Wash trading detection and penalties

### Technical Security
- Order signing prevents spoofing
- Nonce management prevents replay attacks
- Rate limiting prevents spam

### Risk Management
- Real-time mark price calculation
- Insurance fund for socialized losses
- Emergency pause functionality

## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).