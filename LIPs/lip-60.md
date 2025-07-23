---
lip: 60
title: Lending Protocol Standard
description: Defines the standard interface for lending and borrowing protocols on Lux Network
author: Lux Network Team (@luxdefi)
discussions-to: https://forum.lux.network/lip-60
status: Draft
type: Standards Track
category: LRC
created: 2025-01-23
requires: 1, 20, 66
---

## Abstract

This LIP defines a standard interface for lending and borrowing protocols on the Lux Network, enabling interoperable money markets across the ecosystem. The standard covers collateral management, interest rate models, liquidation mechanisms, and cross-chain lending capabilities unique to Lux's multi-chain architecture. The protocol design is inspired by Alchemix's self-repaying loan model, enabling future yield tokenization and automated debt repayment features.

## Motivation

DeFi lending is a cornerstone of any blockchain ecosystem, but Lux lacks standardization for:

1. **Interoperability**: Different lending protocols use incompatible interfaces
2. **Cross-Chain Lending**: No standard for lending across Lux's multiple chains
3. **Risk Management**: Inconsistent approaches to collateral and liquidation
4. **Composability**: Difficult to build on top of existing lending protocols
5. **User Safety**: Varying security practices and parameter management

## Specification

### Core Lending Pool Interface

```solidity
interface ILuxLendingPool {
    // Events
    event Deposit(
        address indexed asset,
        address indexed user,
        address indexed onBehalfOf,
        uint256 amount,
        uint16 referralCode
    );
    
    event Withdraw(
        address indexed asset,
        address indexed user,
        address indexed to,
        uint256 amount
    );
    
    event Borrow(
        address indexed asset,
        address indexed user,
        address indexed onBehalfOf,
        uint256 amount,
        uint256 interestRateMode,
        uint256 borrowRate,
        uint16 referralCode
    );
    
    event Repay(
        address indexed asset,
        address indexed user,
        address indexed repayer,
        uint256 amount
    );
    
    event Liquidation(
        address indexed collateralAsset,
        address indexed debtAsset,
        address indexed user,
        uint256 debtToCover,
        uint256 liquidatedCollateralAmount,
        address liquidator,
        bool receiveAToken
    );
    
    // Core functions
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;
    
    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);
    
    function borrow(
        address asset,
        uint256 amount,
        uint256 interestRateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;
    
    function repay(
        address asset,
        uint256 amount,
        uint256 rateMode,
        address onBehalfOf
    ) external returns (uint256);
    
    function liquidationCall(
        address collateralAsset,
        address debtAsset,
        address user,
        uint256 debtToCover,
        bool receiveAToken
    ) external;
    
    // Flash loan functionality
    function flashLoan(
        address receiverAddress,
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata modes,
        address onBehalfOf,
        bytes calldata params,
        uint16 referralCode
    ) external;
    
    // View functions
    function getUserAccountData(address user) external view returns (
        uint256 totalCollateralUSD,
        uint256 totalDebtUSD,
        uint256 availableBorrowsUSD,
        uint256 currentLiquidationThreshold,
        uint256 ltv,
        uint256 healthFactor
    );
    
    function getReserveData(address asset) external view returns (ReserveData memory);
    function getReservesList() external view returns (address[] memory);
    function getAddressesProvider() external view returns (ILendingPoolAddressesProvider);
}
```

### Reserve Configuration

```solidity
struct ReserveData {
    // Reserve configuration
    ReserveConfigurationMap configuration;
    
    // Liquidity tracking
    uint128 liquidityIndex;
    uint128 variableBorrowIndex;
    uint128 currentLiquidityRate;
    uint128 currentVariableBorrowRate;
    uint128 currentStableBorrowRate;
    
    uint40 lastUpdateTimestamp;
    
    // Token addresses
    address aTokenAddress;
    address stableDebtTokenAddress;
    address variableDebtTokenAddress;
    address interestRateStrategyAddress;
    
    // Reserve ID
    uint8 id;
}

struct ReserveConfigurationMap {
    uint256 data;
}

library ReserveConfiguration {
    uint256 constant LTV_MASK = 0xFFFF;
    uint256 constant LIQUIDATION_THRESHOLD_MASK = 0xFFFF0000;
    uint256 constant LIQUIDATION_BONUS_MASK = 0xFFFF00000000;
    uint256 constant DECIMALS_MASK = 0xFF000000000000;
    uint256 constant ACTIVE_MASK = 0x10000000000000000;
    uint256 constant FROZEN_MASK = 0x20000000000000000;
    uint256 constant BORROWING_MASK = 0x40000000000000000;
    uint256 constant STABLE_BORROWING_MASK = 0x80000000000000000;
    uint256 constant RESERVE_FACTOR_MASK = 0xFFFF000000000000000000;
    
    function setLtv(ReserveConfigurationMap memory self, uint256 ltv) internal pure;
    function getLtv(ReserveConfigurationMap storage self) internal view returns (uint256);
    
    function setLiquidationThreshold(ReserveConfigurationMap memory self, uint256 threshold) internal pure;
    function getLiquidationThreshold(ReserveConfigurationMap storage self) internal view returns (uint256);
    
    function setLiquidationBonus(ReserveConfigurationMap memory self, uint256 bonus) internal pure;
    function getLiquidationBonus(ReserveConfigurationMap storage self) internal view returns (uint256);
    
    function setDecimals(ReserveConfigurationMap memory self, uint256 decimals) internal pure;
    function getDecimals(ReserveConfigurationMap storage self) internal view returns (uint256);
    
    function setActive(ReserveConfigurationMap memory self, bool active) internal pure;
    function getActive(ReserveConfigurationMap storage self) internal view returns (bool);
    
    function setFrozen(ReserveConfigurationMap memory self, bool frozen) internal pure;
    function getFrozen(ReserveConfigurationMap storage self) internal view returns (bool);
    
    function setBorrowingEnabled(ReserveConfigurationMap memory self, bool enabled) internal pure;
    function getBorrowingEnabled(ReserveConfigurationMap storage self) internal view returns (bool);
    
    function setStableRateBorrowingEnabled(ReserveConfigurationMap memory self, bool enabled) internal pure;
    function getStableRateBorrowingEnabled(ReserveConfigurationMap storage self) internal view returns (bool);
    
    function setReserveFactor(ReserveConfigurationMap memory self, uint256 reserveFactor) internal pure;
    function getReserveFactor(ReserveConfigurationMap storage self) internal view returns (uint256);
}
```

### Interest Rate Models

```solidity
interface IInterestRateStrategy {
    function calculateInterestRates(
        uint256 availableLiquidity,
        uint256 totalStableDebt,
        uint256 totalVariableDebt,
        uint256 averageStableBorrowRate,
        uint256 reserveFactor
    ) external view returns (
        uint256 liquidityRate,
        uint256 stableBorrowRate,
        uint256 variableBorrowRate
    );
    
    function getBaseVariableBorrowRate() external view returns (uint256);
    function getMaxVariableBorrowRate() external view returns (uint256);
}

// Standard implementation
contract StandardInterestRateStrategy is IInterestRateStrategy {
    uint256 public immutable OPTIMAL_UTILIZATION_RATE;
    uint256 public immutable EXCESS_UTILIZATION_RATE;
    uint256 public immutable baseVariableBorrowRate;
    uint256 public immutable variableRateSlope1;
    uint256 public immutable variableRateSlope2;
    uint256 public immutable stableRateSlope1;
    uint256 public immutable stableRateSlope2;
    
    constructor(
        uint256 _optimalUtilizationRate,
        uint256 _baseVariableBorrowRate,
        uint256 _variableRateSlope1,
        uint256 _variableRateSlope2,
        uint256 _stableRateSlope1,
        uint256 _stableRateSlope2
    ) {
        OPTIMAL_UTILIZATION_RATE = _optimalUtilizationRate;
        EXCESS_UTILIZATION_RATE = 1e27 - _optimalUtilizationRate;
        baseVariableBorrowRate = _baseVariableBorrowRate;
        variableRateSlope1 = _variableRateSlope1;
        variableRateSlope2 = _variableRateSlope2;
        stableRateSlope1 = _stableRateSlope1;
        stableRateSlope2 = _stableRateSlope2;
    }
    
    function calculateInterestRates(
        uint256 availableLiquidity,
        uint256 totalStableDebt,
        uint256 totalVariableDebt,
        uint256 averageStableBorrowRate,
        uint256 reserveFactor
    ) external view override returns (
        uint256 liquidityRate,
        uint256 stableBorrowRate,
        uint256 variableBorrowRate
    ) {
        uint256 utilizationRate = (totalStableDebt + totalVariableDebt) == 0
            ? 0
            : ((totalStableDebt + totalVariableDebt) * 1e27) / 
              (availableLiquidity + totalStableDebt + totalVariableDebt);
        
        if (utilizationRate > OPTIMAL_UTILIZATION_RATE) {
            uint256 excessUtilizationRateRatio = 
                (utilizationRate - OPTIMAL_UTILIZATION_RATE) * 1e27 / EXCESS_UTILIZATION_RATE;
            
            stableBorrowRate = baseVariableBorrowRate + stableRateSlope1 + 
                stableRateSlope2 * excessUtilizationRateRatio / 1e27;
            
            variableBorrowRate = baseVariableBorrowRate + variableRateSlope1 + 
                variableRateSlope2 * excessUtilizationRateRatio / 1e27;
        } else {
            stableBorrowRate = baseVariableBorrowRate + 
                utilizationRate * stableRateSlope1 / OPTIMAL_UTILIZATION_RATE / 1e27;
            
            variableBorrowRate = baseVariableBorrowRate + 
                utilizationRate * variableRateSlope1 / OPTIMAL_UTILIZATION_RATE / 1e27;
        }
        
        uint256 totalBorrows = totalStableDebt + totalVariableDebt;
        uint256 weightedAvgRate = totalBorrows == 0 ? 0 :
            (totalStableDebt * averageStableBorrowRate + totalVariableDebt * variableBorrowRate) / 
            totalBorrows;
        
        liquidityRate = utilizationRate * weightedAvgRate * (1e27 - reserveFactor) / 1e27 / 1e27;
    }
}
```

### Collateral and Debt Tokens

```solidity
interface IAToken is ILRC20 {
    event Mint(address indexed from, uint256 value, uint256 index);
    event Burn(address indexed from, address indexed target, uint256 value, uint256 index);
    event BalanceTransfer(address indexed from, address indexed to, uint256 value, uint256 index);
    
    function mint(address user, uint256 amount, uint256 index) external returns (bool);
    function burn(address user, address receiverOfUnderlying, uint256 amount, uint256 index) external;
    function mintToTreasury(uint256 amount, uint256 index) external;
    function transferOnLiquidation(address from, address to, uint256 value) external;
    function transferUnderlyingTo(address target, uint256 amount) external returns (uint256);
    
    function getScaledUserBalanceAndSupply(address user) external view returns (uint256, uint256);
    function scaledBalanceOf(address user) external view returns (uint256);
    function scaledTotalSupply() external view returns (uint256);
    
    function UNDERLYING_ASSET_ADDRESS() external view returns (address);
    function POOL() external view returns (ILendingPool);
}

interface IDebtToken is ILRC20 {
    event Mint(address indexed user, address indexed onBehalfOf, uint256 amount, uint256 currentBalance, uint256 balanceIncrease, uint256 newRate, uint256 avgStableRate, uint256 newTotalSupply);
    event Burn(address indexed user, uint256 amount, uint256 currentBalance, uint256 balanceIncrease, uint256 avgStableRate, uint256 newTotalSupply);
    
    function mint(address user, address onBehalfOf, uint256 amount, uint256 rate) external returns (bool);
    function burn(address user, uint256 amount) external;
    
    function getAverageStableRate() external view returns (uint256);
    function getUserStableRate(address user) external view returns (uint256);
    function getUserLastUpdated(address user) external view returns (uint40);
    function getSupplyData() external view returns (uint256, uint256, uint256, uint40);
    function getTotalSupplyLastUpdated() external view returns (uint40);
    function getTotalSupplyAndAvgRate() external view returns (uint256, uint256);
    function principalBalanceOf(address user) external view returns (uint256);
}
```

### Price Oracle Interface

```solidity
interface IPriceOracle {
    function getAssetPrice(address asset) external view returns (uint256);
    function getAssetsPrices(address[] calldata assets) external view returns (uint256[] memory);
    function getSourceOfAsset(address asset) external view returns (address);
    function getFallbackOracle() external view returns (address);
}
```

### Liquidation Manager

```solidity
interface ILiquidationManager {
    struct LiquidationCallParams {
        address collateralAsset;
        address debtAsset;
        address user;
        uint256 debtToCover;
        bool receiveAToken;
    }
    
    function liquidationCall(
        LiquidationCallParams memory params
    ) external returns (uint256, uint256);
    
    function getUserLiquidationData(
        address user,
        address collateralAsset,
        address debtAsset
    ) external view returns (
        uint256 maxLiquidatableDebt,
        uint256 collateralToLiquidate,
        uint256 liquidationBonus
    );
}
```

### Cross-Chain Lending

```solidity
interface ICrossChainLending {
    struct CrossChainDeposit {
        bytes32 depositId;
        address asset;
        uint256 amount;
        string sourceChain;
        string destinationChain;
        address depositor;
        uint256 timestamp;
    }
    
    struct CrossChainBorrow {
        bytes32 borrowId;
        address asset;
        uint256 amount;
        address collateralAsset;
        uint256 collateralAmount;
        string collateralChain;
        string borrowChain;
        address borrower;
        uint256 timestamp;
    }
    
    // Cross-chain operations
    function initiateCrossChainDeposit(
        address asset,
        uint256 amount,
        string memory destinationChain
    ) external returns (bytes32 depositId);
    
    function completeCrossChainDeposit(
        bytes32 depositId,
        bytes memory proof
    ) external;
    
    function initiateCrossChainBorrow(
        address borrowAsset,
        uint256 borrowAmount,
        string memory borrowChain,
        address collateralAsset,
        uint256 collateralAmount,
        string memory collateralChain
    ) external returns (bytes32 borrowId);
    
    function getCrossChainPosition(
        address user
    ) external view returns (
        CrossChainDeposit[] memory deposits,
        CrossChainBorrow[] memory borrows
    );
}
```

### Alchemix-Style Self-Repaying Loans

```solidity
interface ISelfRepayingLoans {
    // Yield tokenization
    struct YieldToken {
        address underlying;          // Base asset (e.g., DAI)
        address yieldBearing;       // Yield source (e.g., yvDAI)
        address synthetic;          // Synthetic asset (e.g., alUSD)
        uint256 expectedYield;      // Annual percentage yield
        uint256 harvestInterval;    // How often to harvest
    }
    
    // Self-repaying loan position
    struct AlchemixPosition {
        address owner;
        address collateral;         // Yield-bearing collateral
        address debt;              // Synthetic debt asset
        uint256 collateralAmount;
        uint256 debtAmount;
        uint256 yieldAccrued;
        uint256 lastHarvest;
    }
    
    // Core Alchemix-style functions
    function depositAndBorrow(
        address yieldToken,
        uint256 collateralAmount,
        uint256 borrowAmount
    ) external returns (uint256 positionId);
    
    function harvestYield(uint256 positionId) external returns (uint256 yieldAmount);
    
    function repayWithYield(uint256 positionId) external;
    
    function liquidateSelfRepaying(
        uint256 positionId,
        uint256 amount
    ) external;
    
    // View functions
    function getTimeToRepay(uint256 positionId) external view returns (uint256);
    function getAccruedYield(uint256 positionId) external view returns (uint256);
    function getMaxBorrowable(address yieldToken, uint256 collateral) external view returns (uint256);
}

// Transmuter for synthetic to underlying conversion
interface ITransmuter {
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function claim(uint256 amount) external;
    function getClaimableBalance(address user) external view returns (uint256);
    function getTransmuterBuffer() external view returns (uint256);
}
```

### Flash Loan Receiver

```solidity
interface IFlashLoanReceiver {
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external returns (bool);
    
    function ADDRESSES_PROVIDER() external view returns (ILendingPoolAddressesProvider);
    function LENDING_POOL() external view returns (ILendingPool);
}
```

### Risk Parameters

```solidity
struct RiskParameters {
    uint256 ltv;                      // Loan-to-value ratio (0-10000 = 0-100%)
    uint256 liquidationThreshold;     // Liquidation threshold (0-10000)
    uint256 liquidationBonus;         // Liquidation incentive (0-10000)
    uint256 reserveFactor;            // Reserve factor (0-10000)
    bool borrowingEnabled;
    bool stableBorrowRateEnabled;
    bool isActive;
    bool isFrozen;
}

interface IRiskParameterManager {
    function setRiskParameters(
        address asset,
        RiskParameters memory params
    ) external;
    
    function getRiskParameters(
        address asset
    ) external view returns (RiskParameters memory);
    
    function validateHealthFactor(
        address user,
        address asset,
        uint256 amount,
        uint256 operationType
    ) external view returns (bool);
}
```

## Rationale

### Design Decisions

1. **Modular Architecture**: Separate contracts for pools, tokens, oracles, and strategies
2. **Cross-Chain Native**: Built-in support for Lux's multi-chain architecture
3. **Gas Optimization**: Efficient storage patterns and calculation methods
4. **Risk Isolation**: Each asset has independent risk parameters
5. **Upgradability**: Proxy patterns for critical components

### Security Features

1. **Health Factor**: Continuous monitoring of collateralization
2. **Liquidation Incentives**: Balanced to ensure market efficiency
3. **Oracle Redundancy**: Multiple price sources with fallbacks
4. **Pause Mechanisms**: Emergency controls for each market
5. **Access Controls**: Role-based permissions for admin functions

## Backwards Compatibility

This standard is designed to be compatible with:
- Existing DeFi lending protocols (Aave, Compound patterns)
- LRC-20 token standard (LIP-20)
- Oracle standards (LIP-66)

## Test Cases

### Deposit and Borrow Test
```solidity
function testDepositAndBorrow() public {
    // Setup
    uint256 depositAmount = 1000 * 10**18;
    uint256 borrowAmount = 500 * 10**6; // USDC
    
    // Deposit collateral
    collateralToken.approve(address(lendingPool), depositAmount);
    lendingPool.deposit(address(collateralToken), depositAmount, user, 0);
    
    // Verify aToken balance
    IAToken aToken = IAToken(lendingPool.getReserveData(address(collateralToken)).aTokenAddress);
    assertEq(aToken.balanceOf(user), depositAmount);
    
    // Borrow against collateral
    lendingPool.borrow(address(borrowToken), borrowAmount, 2, 0, user);
    
    // Verify borrowed amount
    assertEq(borrowToken.balanceOf(user), borrowAmount);
    
    // Check health factor
    (,,,,, uint256 healthFactor) = lendingPool.getUserAccountData(user);
    assert(healthFactor > 1e18); // Health factor > 1
}
```

### Liquidation Test
```solidity
function testLiquidation() public {
    // Setup underwater position
    // ... (deposit and borrow setup)
    
    // Simulate price drop
    oracle.setAssetPrice(address(collateralToken), initialPrice * 70 / 100);
    
    // Check liquidation available
    (uint256 maxDebt,,) = liquidationManager.getUserLiquidationData(
        borrower,
        address(collateralToken),
        address(borrowToken)
    );
    assert(maxDebt > 0);
    
    // Execute liquidation
    uint256 debtToCover = maxDebt / 2;
    borrowToken.approve(address(lendingPool), debtToCover);
    lendingPool.liquidationCall(
        address(collateralToken),
        address(borrowToken),
        borrower,
        debtToCover,
        true // receive aToken
    );
    
    // Verify liquidation bonus received
    uint256 expectedBonus = debtToCover * 105 / 100; // 5% bonus
    // ... verify liquidator received bonus
}
```

### Flash Loan Test
```solidity
contract FlashLoanTest is IFlashLoanReceiver {
    function testFlashLoan() public {
        address[] memory assets = new address[](1);
        assets[0] = address(borrowToken);
        
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1000000 * 10**6; // 1M USDC
        
        uint256[] memory modes = new uint256[](1);
        modes[0] = 0; // No debt
        
        lendingPool.flashLoan(
            address(this),
            assets,
            amounts,
            modes,
            address(this),
            "",
            0
        );
    }
    
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        // Perform arbitrage or other operations
        
        // Approve repayment
        for (uint i = 0; i < assets.length; i++) {
            uint256 amountOwing = amounts[i] + premiums[i];
            IERC20(assets[i]).approve(address(LENDING_POOL), amountOwing);
        }
        
        return true;
    }
}
```

## Reference Implementation

Reference implementations available at:
- https://github.com/luxdefi/lending-protocol
- https://github.com/luxdefi/finance
- https://github.com/alchemix-finance/alchemix-protocol (Alchemix reference)

Key features:
- Multi-chain collateral support
- Dynamic interest rate models
- Efficient liquidation engine
- Cross-chain position management
- Alchemix-inspired self-repaying loans
- Yield tokenization and harvesting
- Synthetic asset transmutation

## Security Considerations

### Oracle Risks
- Price manipulation attacks
- Oracle downtime handling
- Cross-chain price consistency
- Implement circuit breakers for extreme price movements

### Liquidation Risks
- MEV protection for liquidations
- Fair liquidation ordering
- Partial liquidation support
- Liquidation bot ecosystem health

### Cross-Chain Risks
- Message verification across chains
- Handling chain reorganizations
- Ensuring atomic operations
- Bridge security dependencies

### Economic Risks
- Interest rate model validation
- Reserve factor optimization
- Preventing bank runs
- Managing protocol insolvency

### Smart Contract Risks
- Reentrancy protection
- Integer overflow/underflow
- Access control verification
- Upgrade mechanism security

## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).