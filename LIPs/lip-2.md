---
lip: 2
title: Liquidity Pool Standard
description: Defines the standard interface and mechanisms for liquidity pools on Lux Network
author: Lux Network Team (@luxdefi)
discussions-to: https://forum.lux.network/lip-2
status: Draft
type: Standards Track
category: LRC
created: 2025-01-23
requires: 1, 20
---

## Abstract

This LIP defines a standard interface for liquidity pools on the Lux Network, enabling decentralized trading, automated market making (AMM), and liquidity provision. The standard ensures interoperability between different DeFi protocols and provides a consistent interface for liquidity management across the ecosystem.

## Motivation

Liquidity is the foundation of any decentralized financial ecosystem. By establishing a standard for liquidity pools early in the Lux Network's development, we ensure:

1. **Consistency**: All protocols can interact with liquidity pools using the same interface
2. **Composability**: DeFi protocols can build on top of standardized liquidity primitives
3. **Security**: Well-defined standards reduce implementation errors
4. **Efficiency**: Optimized patterns for gas-efficient liquidity operations
5. **Interoperability**: Seamless integration with cross-chain liquidity through M-Chain

## Specification

### Core Liquidity Pool Interface

```solidity
interface ILuxLiquidityPool {
    // Events
    event LiquidityAdded(
        address indexed provider,
        uint256 tokenAAmount,
        uint256 tokenBAmount,
        uint256 liquidity
    );
    
    event LiquidityRemoved(
        address indexed provider,
        uint256 tokenAAmount,
        uint256 tokenBAmount,
        uint256 liquidity
    );
    
    event Swap(
        address indexed user,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );
    
    event FeesCollected(
        address indexed token,
        uint256 amount
    );
    
    // View functions
    function getReserves() external view returns (uint256 reserveA, uint256 reserveB);
    function getPrice(address token) external view returns (uint256);
    function getLiquidityToken() external view returns (address);
    function getFeeRate() external view returns (uint256);
    function totalLiquidity() external view returns (uint256);
    
    // Liquidity management
    function addLiquidity(
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
    
    function removeLiquidity(
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
    
    // Trading
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    
    // Price calculation
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) 
        external pure returns (uint256 amountOut);
        
    function getAmountIn(uint256 amountOut, uint256 reserveIn, uint256 reserveOut) 
        external pure returns (uint256 amountIn);
}
```

### Liquidity Token Standard

Liquidity tokens MUST implement the LRC-20 standard (defined in LIP-20) with additional metadata:

```solidity
interface ILiquidityToken is ILRC20 {
    function pool() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
}
```

### Fee Structure

Pools MUST implement a transparent fee structure:

```solidity
struct FeeStructure {
    uint256 swapFee;        // Fee taken on swaps (basis points)
    uint256 protocolFee;    // Fee allocated to protocol (basis points)
    uint256 lpFee;          // Fee allocated to liquidity providers (basis points)
}
```

### Cross-Chain Liquidity

For cross-chain liquidity through M-Chain:

```solidity
interface ICrossChainLiquidity {
    function bridgeLiquidity(
        uint256 amount,
        uint256 targetChainId,
        address recipient
    ) external returns (bytes32 bridgeId);
    
    function receiveBridgedLiquidity(
        bytes32 bridgeId,
        uint256 amount,
        address provider
    ) external;
}
```

## Rationale

### Design Decisions

1. **Unified Interface**: The standard provides a common interface while allowing implementation flexibility
2. **Native LUX Integration**: Designed to work seamlessly with the native LUX token (LIP-1)
3. **Cross-Chain Ready**: Built with M-Chain integration in mind for cross-chain liquidity
4. **Gas Optimization**: Interface designed for efficient implementation
5. **Composability**: Works with existing token standards (LRC-20)

### Security Considerations

1. **Reentrancy Protection**: Implementations MUST guard against reentrancy attacks
2. **Slippage Protection**: Built-in minimum amount parameters
3. **Deadline Mechanism**: Prevents stale transactions
4. **Price Manipulation**: Implementations should consider TWAP oracles

## Backwards Compatibility

This standard is designed to be compatible with:
- LIP-1 (Native LUX Token)
- LIP-20 (LRC-20 Token Standard)
- Existing AMM protocols (Uniswap V2/V3 patterns)

## Test Cases

### Basic Liquidity Operations

```solidity
// Test adding liquidity
function testAddLiquidity() {
    uint256 amountA = 1000 * 10**18;
    uint256 amountB = 2000 * 10**18;
    
    (uint256 actualA, uint256 actualB, uint256 liquidity) = pool.addLiquidity(
        amountA,
        amountB,
        amountA * 95 / 100,  // 5% slippage
        amountB * 95 / 100,
        address(this),
        block.timestamp + 300
    );
    
    assert(liquidity > 0);
    assert(actualA <= amountA);
    assert(actualB <= amountB);
}

// Test swap
function testSwap() {
    uint256 amountIn = 100 * 10**18;
    address[] memory path = new address[](2);
    path[0] = tokenA;
    path[1] = tokenB;
    
    uint256[] memory amounts = pool.swapExactTokensForTokens(
        amountIn,
        0,  // Calculate minimum separately
        path,
        address(this),
        block.timestamp + 300
    );
    
    assert(amounts[0] == amountIn);
    assert(amounts[1] > 0);
}
```

## Reference Implementation

A reference implementation is available at:
https://github.com/luxdefi/liquidity-standard

Key features:
- Constant product AMM (x*y=k)
- 0.3% default swap fee
- LP token implementation
- Cross-chain bridge integration

## Security Considerations

### Price Manipulation
Liquidity pools are susceptible to price manipulation through large trades or flash loans. Implementations should:
- Use time-weighted average prices (TWAP) for critical operations
- Implement maximum slippage controls
- Consider multi-block MEV protection

### Impermanent Loss
Liquidity providers face impermanent loss risk. Implementations should:
- Provide clear IL calculations
- Offer IL protection mechanisms where appropriate
- Enable dynamic fee adjustment based on volatility

### Cross-Chain Risks
When implementing cross-chain liquidity:
- Ensure atomic operations or proper rollback mechanisms
- Validate bridge message authenticity
- Implement emergency pause functionality

## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).