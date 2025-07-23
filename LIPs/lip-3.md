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

### API Specification - FIX 4.4 Aligned

#### REST API
```typescript
// Place order - FIX field naming convention
POST /api/v1/orders
{
    "symbol": "BTCUSDC",          // FIX Tag 55 (Symbol)
    "side": "BUY",                // FIX Tag 54 (Side: BUY=1, SELL=2)
    "orderType": "LIMIT",         // FIX Tag 40 (OrdType)
    "price": 63201587000,         // FIX Tag 44 (63,201.587 USDC in 1e-6)
    "orderQty": 250000000,        // FIX Tag 38 (0.25 BTC in 1e-6)
    "timeInForce": "POST_ONLY",   // FIX Tag 59/18 (ExecInst=P)
    "clientOrderId": "ABC-123",   // FIX Tag 11 (ClOrdID)
    "cashOrderQty": 15800396750,  // FIX Tag 152 (notional USD)
    "leverage": 10,               // Custom field
    "execInst": "P"               // FIX Tag 18 (P=PostOnly, R=ReduceOnly)
}

// Cancel order - FIX compliant
DELETE /api/v1/orders/{orderId}
{
    "clientOrderId": "ABC-123",   // FIX Tag 11
    "symbol": "BTCUSDC"           // FIX Tag 55
}

// Order status response - Execution Report (35=8)
{
    "orderId": "123456",          // FIX Tag 37
    "clientOrderId": "ABC-123",   // FIX Tag 11
    "symbol": "BTCUSDC",          // FIX Tag 55
    "side": "BUY",                // FIX Tag 54
    "orderQty": 250000000,        // FIX Tag 38
    "price": 63201587000,         // FIX Tag 44
    "execType": "NEW",            // FIX Tag 150 (0=New)
    "ordStatus": "NEW",           // FIX Tag 39 (0=New)
    "leavesQty": 250000000,       // FIX Tag 151
    "cumQty": 0,                  // FIX Tag 14
    "avgPx": 0,                   // FIX Tag 6
    "transactTime": 1674234567890 // FIX Tag 60
}

// Get order book
GET /api/v1/markets/{symbol}/orderbook?depth=20

// Get positions with signed quantity
GET /api/v1/positions
{
    "positions": [{
        "symbol": "BTCUSDC",      // FIX Tag 55
        "posQty": 500000000,      // FIX Tag 704 (PosQty)
        "longQty": 500000000,     // FIX Tag 705 
        "shortQty": 0,            // FIX Tag 705
        "posQtySigned": 500000000,// + for long, - for short
        "avgPx": 62500000000,     // FIX Tag 6 (AvgPx)
        "realizedPnl": 0,         // FIX Tag 8009
        "unrealizedPnl": 350793500 // Custom field
    }]
}
```

#### WebSocket Streams - FIX Aligned
```typescript
// Order book updates - Market Data Request (35=V)
ws.subscribe({
    "msgType": "V",               // FIX MsgType 35=V
    "channel": "orderbook", 
    "symbol": "BTCUSDC",          // FIX Tag 55
    "marketDepth": 10,            // FIX Tag 264
    "subscriptionRequestType": 1   // FIX Tag 263 (1=Subscribe)
});

// Market data snapshot/update (35=W)
{
    "msgType": "W",               // FIX MsgType 35=W
    "symbol": "BTCUSDC",          // FIX Tag 55
    "mdEntries": [{
        "mdEntryType": "0",       // FIX Tag 269 (0=Bid)
        "mdEntryPx": 63200000000, // FIX Tag 270 (Price)
        "mdEntrySize": 500000000, // FIX Tag 271 (Size)
        "mdEntryTime": 1674234567890 // FIX Tag 273
    }]
}

// Trade feed - Trade Capture Report (35=AE)
ws.subscribe({
    "msgType": "AE",              // FIX MsgType 35=AE
    "channel": "trades",
    "symbol": "BTCUSDC"           // FIX Tag 55
});

// Execution reports for own orders (35=8)
ws.subscribe({
    "msgType": "8",               // FIX MsgType 35=8
    "channel": "executions",
    "auth": true
});
```

### FIX Gateway Integration

The LX Exchange provides native FIX 4.4 gateway for institutional traders:

```typescript
// FIX Session Configuration
interface FIXConfig {
    beginString: "FIX.4.4";       // FIX Tag 8
    senderCompID: string;         // FIX Tag 49
    targetCompID: "LUXEXCHANGE";  // FIX Tag 56
    heartBtInt: 30;               // FIX Tag 108 (30 seconds)
    encryptMethod: 0;             // FIX Tag 98 (None)
}

// FIX Message Examples

// New Order Single (35=D)
8=FIX.4.4|9=246|35=D|34=1080|49=CLIENT1|52=20240115-10:30:00.000|
56=LUXEXCHANGE|11=ABC-123|21=1|55=BTCUSDC|54=1|60=20240115-10:30:00.000|
38=250000000|40=2|44=63201587000|59=0|18=P|10=128|

// Execution Report (35=8)
8=FIX.4.4|9=378|35=8|34=2304|49=LUXEXCHANGE|52=20240115-10:30:00.123|
56=CLIENT1|6=63201587000|11=ABC-123|14=0|17=EXEC123456|20=0|21=1|
31=0|32=0|37=ORD789012|38=250000000|39=0|40=2|44=63201587000|54=1|
55=BTCUSDC|59=0|60=20240115-10:30:00.123|150=0|151=250000000|10=215|

// Order Cancel Request (35=F)
8=FIX.4.4|9=156|35=F|34=1081|49=CLIENT1|52=20240115-10:31:00.000|
56=LUXEXCHANGE|11=ABC-124|37=ORD789012|41=ABC-123|54=1|55=BTCUSDC|
60=20240115-10:31:00.000|10=089|
```

### FIX to REST/WebSocket Mapping

| FIX Field | FIX Tag | JSON Field | Type | Notes |
|-----------|---------|------------|------|-------|
| Price | 44 | price | uint256 | 1e-6 precision |
| OrderQty | 38 | orderQty | uint256 | 1e-6 precision |
| Symbol | 55 | symbol | string | BTCUSDC format |
| Side | 54 | side | string | BUY/SELL in JSON |
| OrdType | 40 | orderType | string | MARKET/LIMIT/STOP |
| TimeInForce | 59 | timeInForce | string | GTC/IOC/FOK/GTD |
| ExecInst | 18 | execInst | string | P=PostOnly, R=ReduceOnly |
| ClOrdID | 11 | clientOrderId | string | Client's order ID |
| OrderID | 37 | orderId | string | Exchange order ID |
| ExecType | 150 | execType | string | Execution type |
| OrdStatus | 39 | ordStatus | string | Order status |
| LastPx | 31 | lastPx | uint256 | Fill price |
| LastQty | 32 | lastQty | uint256 | Fill quantity |
| LeavesQty | 151 | leavesQty | uint256 | Remaining quantity |
| CumQty | 14 | cumQty | uint256 | Total filled |
| AvgPx | 6 | avgPx | uint256 | VWAP |

### Performance Targets

| Metric | Target | Method |
|--------|--------|--------|
| Order Latency | <200ms | Direct X-Chain submission |
| Throughput | 100,000 orders/sec | GPU acceleration |
| Book Depth | 1000 levels | Optimized data structures |
| Settlement | Instant | X-Chain native |

### FIX Protocol Implementation Details

#### Message Flow
```
┌─────────┐    FIX 4.4    ┌─────────────┐    Native    ┌──────────┐
│ TradFi  │────────────────│ FIX Gateway │──────────────│ Matching │
│ Client  │                │  (Adaptor)  │              │  Engine  │
└─────────┘                └─────────────┘              └──────────┘
     │                            │                           │
     │ 35=D (NewOrderSingle)      │                           │
     │─────────────────────────>  │                           │
     │                            │ Convert to Native          │
     │                            │────────────────────────>   │
     │                            │                           │
     │                            │   Native Execution        │
     │                            │<────────────────────────   │
     │ 35=8 (ExecutionReport)     │                           │
     │<─────────────────────────  │                           │
```

#### Order Type Mappings
```solidity
// FIX to Native conversion
function convertFIXOrder(FIXOrder memory fixOrder) internal pure returns (Order memory) {
    Order memory order;
    
    // Symbol mapping (Tag 55)
    order.symbol = fixOrder.symbol;
    
    // Side mapping (Tag 54)
    order.side = fixOrder.side == '1' ? Side.BUY : Side.SELL;
    
    // Order type mapping (Tag 40)
    if (fixOrder.ordType == '1') order.orderType = OrderType.MARKET;
    else if (fixOrder.ordType == '2') order.orderType = OrderType.LIMIT;
    else if (fixOrder.ordType == '3') order.orderType = OrderType.STOP;
    else if (fixOrder.ordType == '4') order.orderType = OrderType.STOP_LIMIT;
    else if (fixOrder.ordType == 'P') order.orderType = OrderType.PEGGED;
    
    // Time in Force mapping (Tag 59 + Tag 18)
    if (fixOrder.timeInForce == '0') order.timeInForce = TimeInForce.GTC;
    else if (fixOrder.timeInForce == '3') order.timeInForce = TimeInForce.IOC;
    else if (fixOrder.timeInForce == '4') order.timeInForce = TimeInForce.FOK;
    else if (fixOrder.timeInForce == '6') order.timeInForce = TimeInForce.GTD;
    
    // Special handling for Post-Only via ExecInst
    if (fixOrder.execInst == 'P') order.timeInForce = TimeInForce.POST_ONLY;
    
    // Price and quantity (micro-units)
    order.price = fixOrder.price;         // Tag 44
    order.orderQty = fixOrder.orderQty;   // Tag 38
    order.clientOrderId = fixOrder.clOrdID; // Tag 11
    
    return order;
}
```

#### Database Schema - FIX Aligned
```sql
CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,           -- FIX Tag 37
    client_order_id VARCHAR(64) NOT NULL,  -- FIX Tag 11
    symbol VARCHAR(16) NOT NULL,           -- FIX Tag 55
    side SMALLINT NOT NULL,                -- FIX Tag 54 (1=Buy, 2=Sell)
    order_type SMALLINT NOT NULL,          -- FIX Tag 40
    price BIGINT NOT NULL,                 -- FIX Tag 44 (micro-units)
    order_qty BIGINT NOT NULL,             -- FIX Tag 38 (micro-units)
    time_in_force SMALLINT NOT NULL,       -- FIX Tag 59
    exec_inst VARCHAR(8),                  -- FIX Tag 18
    order_status CHAR(1) NOT NULL,         -- FIX Tag 39
    cum_qty BIGINT DEFAULT 0,              -- FIX Tag 14
    leaves_qty BIGINT NOT NULL,            -- FIX Tag 151
    avg_px BIGINT DEFAULT 0,               -- FIX Tag 6
    transact_time BIGINT NOT NULL,         -- FIX Tag 60
    
    INDEX idx_symbol_side (symbol, side),
    INDEX idx_client_order_id (client_order_id),
    INDEX idx_transact_time (transact_time)
);

CREATE TABLE executions (
    exec_id BIGINT PRIMARY KEY,            -- FIX Tag 17
    order_id BIGINT NOT NULL,              -- FIX Tag 37
    exec_type CHAR(1) NOT NULL,            -- FIX Tag 150
    last_px BIGINT NOT NULL,               -- FIX Tag 31
    last_qty BIGINT NOT NULL,              -- FIX Tag 32
    exec_time BIGINT NOT NULL,             -- Timestamp
    
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
```

#### Logging Format - FIX Aligned
```json
{
    "timestamp": 1674234567890,
    "msgType": "D",                        // FIX Tag 35
    "clientOrderId": "ABC-123",            // FIX Tag 11
    "symbol": "BTCUSDC",                   // FIX Tag 55
    "side": "BUY",                         // FIX Tag 54
    "orderType": "LIMIT",                  // FIX Tag 40
    "price": 63201587000,                  // FIX Tag 44
    "orderQty": 250000000,                 // FIX Tag 38
    "timeInForce": "POST_ONLY",            // FIX Tag 59/18
    "event": "ORDER_RECEIVED"
}
```

## Rationale

### Design Decisions

1. **X-Chain Integration**: Built directly on X-Chain for maximum performance
2. **Cancel-First**: Protects market makers from adverse selection
3. **GPU Acceleration**: Leverages Hanzo for complex risk calculations
4. **Portfolio Margining**: Maximizes capital efficiency for traders
5. **Native Settlement**: No wrapped tokens or synthetic assets
6. **FIX 4.4 Alignment**: 
   - Familiar to institutional traders from TradFi
   - Enables trivial FIX gateway implementation
   - Standardized field names reduce integration time
   - Compatible with existing trading infrastructure
   - Consistent micro-unit pricing (1e-6) prevents float drift

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

## Appendix: FIX 4.4 Field Reference

### Core Order Fields
| Field Name | FIX Tag | JSON Field | Values | Description |
|------------|---------|------------|--------|-------------|
| BeginString | 8 | - | FIX.4.4 | Protocol version |
| MsgType | 35 | msgType | D,F,G,8,9,AE,V,W | Message type |
| Symbol | 55 | symbol | BTCUSDC, LUXUSDC | Trading pair |
| Side | 54 | side | 1=Buy, 2=Sell | Order side |
| OrderQty | 38 | orderQty | Micro-units (1e-6) | Order quantity |
| Price | 44 | price | Micro-units (1e-6) | Limit price |
| OrdType | 40 | orderType | 1=Market, 2=Limit, 3=Stop, 4=StopLimit | Order type |
| TimeInForce | 59 | timeInForce | 0=GTC, 3=IOC, 4=FOK, 6=GTD | Time constraint |
| ExecInst | 18 | execInst | P=PostOnly, R=ReduceOnly | Special instructions |
| ClOrdID | 11 | clientOrderId | String | Client order ID |
| OrderID | 37 | orderId | String | Exchange order ID |

### Execution Fields
| Field Name | FIX Tag | JSON Field | Values | Description |
|------------|---------|------------|--------|-------------|
| ExecID | 17 | execId | String | Execution ID |
| ExecType | 150 | execType | 0=New, 1=Partial, 2=Fill, 4=Cancel | Execution type |
| OrdStatus | 39 | ordStatus | 0=New, 1=PartiallyFilled, 2=Filled | Order status |
| LastPx | 31 | lastPx | Micro-units | Fill price |
| LastQty | 32 | lastQty | Micro-units | Fill quantity |
| LeavesQty | 151 | leavesQty | Micro-units | Remaining quantity |
| CumQty | 14 | cumQty | Micro-units | Total filled |
| AvgPx | 6 | avgPx | Micro-units | Average fill price |

### Market Data Fields
| Field Name | FIX Tag | JSON Field | Values | Description |
|------------|---------|------------|--------|-------------|
| MDEntryType | 269 | mdEntryType | 0=Bid, 1=Offer, 2=Trade | Market data type |
| MDEntryPx | 270 | mdEntryPx | Micro-units | Price level |
| MDEntrySize | 271 | mdEntrySize | Micro-units | Size at level |
| MDEntryTime | 273 | mdEntryTime | Timestamp | Update time |

### Position Fields
| Field Name | FIX Tag | JSON Field | Values | Description |
|------------|---------|------------|--------|-------------|
| PosQty | 704 | posQty | Unsigned quantity | Position quantity |
| LongQty | 705 | longQty | Positive value | Long position |
| ShortQty | 705 | shortQty | Positive value | Short position |
| - | - | posQtySigned | Signed quantity | +Long, -Short |

### Additional Fields
| Field Name | FIX Tag | JSON Field | Values | Description |
|------------|---------|------------|--------|-------------|
| CashOrderQty | 152 | cashOrderQty | USD micro-units | Notional value |
| StopPx | 99 | stopPx | Micro-units | Stop trigger price |
| ExpireTime | 126 | expireTime | Timestamp | GTD expiration |
| TransactTime | 60 | transactTime | Timestamp | Transaction time |
| Text | 58 | text | String | Reject reason |
| PossDupFlag | 43 | possDupFlag | Y/N | Possible duplicate |
| OrigClOrdID | 41 | origClientOrderId | String | Original order ID |

## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).