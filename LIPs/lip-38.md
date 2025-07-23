---
lip: 38
title: Lux Exchange (LX) Trading Protocol
description: A fully decentralized on‑chain automated liquidity provision strategy for early tokens via native order‑book integration
author: Lux Network Team
discussions-to: <URL>
status: Draft
type: Standards Track
category: LRC
created: 2025-07-24
requires: 20
---

## Abstract

LIP-38 defines LX, a permissionless, decentralized liquidity provision strategy that bootstrap deep, tight markets for tokens in early phases of price discovery. LX combines automated order-book placements with Uniswap-inspired range logic and integrates directly into the native on-chain order book without requiring centralized operators.

## Motivation

While LIP-1 provides a permissionless token standard, early-phase assets often lack liquidity. LX’s core principle is democratized liquidity: Mirroring CEX perp/spot prices for perps, we need an on-chain strategy for LIP-1 tokens. LX ensures continuous, parameterized market‑making secured by the same consensus operating the DEX.

## Specification

LX is fully specified by parameters:

| Parameter       | Description                                                                         |
|-----------------|-------------------------------------------------------------------------------------|
| spot            | Spot asset code (e.g. LUX coin) with USDC quote                                     |
| startPx         | Initial price of the range                                                          |
| nOrders         | Number of discrete orders in the price range                                        |
| orderSz         | Size of each full order (in quote units)                                            |
| nSeededLevels   | Number of bid levels seeded at genesis; reduces total supply per extra level        |

Price range recursion:
```
px_0 = startPx
px_i = round(px_{i-1} * 1.003)
```

Update rules (every block with ≥ 3s since last update):

1. Compute nFull = floor(balance / orderSz) and remainder = balance % orderSz.
2. Place up to nFull full ask orders at px_i and a single partial ask of size=remainder if remainder>0.
3. Flip fully filled orders to bids when balance allows, maintaining the range.

This guarantees a ~0.3% spread updated every ~3 s. Any active LP can join alongside LX orders.

## Rationale

LX provides continuous, decentralized market‑making without operators. By integrating into the native on-chain order book, it leverages existing DEX execution and ensures fair, on‑chain enforcement of strategy logic.

## Backwards Compatibility

LX is an optional X-Chain extension. Lux Nodes without the strategy enabled run standard order-book behavior unchanged.

## Test Cases

1. Genesis: validate px_0…px_{nOrders−1} levels and seeded bids count.
2. Update: simulate balance changes and ensure orders follow algorithm.
3. Partial orders: verify nonzero remainder case.
4. Multi-LP integration: LX orders coexist with user orders.

## Reference Implementation

See the `lx` plugin under `plugins-core/dex`:
```
plugins-core/dex/lx
├─ strategy.go   # core logic
├─ params.go     # config types
└─ strategy_test.go
```

## Security Considerations

- Enforce spacing between updates to prevent flash‑spam (min 3 s).
- Validate parameters on deployment to avoid extreme ranges or overflow.
- Guard gas usage per update to avoid DoS.

## Economic Impact (optional)

LX may lock significant USDC collateral. Operators bear funding cost in exchange for LP fees. Strategy reduces arbitrageable spreads, improving market efficiency.

## Open Questions (optional)

1. Optimal price multiplier (1.003) and update interval trade‑offs?
2. Dynamic rebalancing across multiple markets?
3. Integration with ZK‑enabled private liquidity provision?

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
