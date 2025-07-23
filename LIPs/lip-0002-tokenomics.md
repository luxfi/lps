# LIP-002: Lux Network Tokenomics

**LIP Number**: 002  
**Title**: LUX Token Economics and Distribution  
**Author**: Lux Network Team  
**Status**: Draft  
**Type**: Economic  
**Created**: 2025-01-22  

## Abstract

This LIP defines the tokenomics of the Lux Network, including token distribution, emission schedule, staking rewards, fee structures, and economic incentives across all chains. The LUX token serves as the native asset for staking, governance, and fees throughout the network.

## Motivation

A well-designed token economy ensures:
1. **Network Security** through adequate staking incentives
2. **Sustainable Growth** via controlled emission
3. **Fair Distribution** among stakeholders
4. **Economic Alignment** between users, validators, and developers

## Token Overview

### Basic Parameters

```
Token Name: Lux
Token Symbol: LUX
Decimals: 9
Total Supply: 720,000,000 LUX (fixed)
Initial Supply: 360,000,000 LUX
```

### Token Utility

1. **Staking**: Secure the network as a validator or delegator
2. **Fees**: Pay for transactions and computational resources
3. **Governance**: Vote on network upgrades and parameters
4. **Bridge Fees**: Pay for cross-chain transfers
5. **Exchange Fees**: Trading fees on X-Chain exchange

## Token Distribution

### Initial Allocation (360M LUX)

| Category | Amount | Percentage | Vesting |
|----------|--------|------------|---------|
| Team & Advisors | 36M | 10% | 4 years, 1 year cliff |
| Foundation | 90M | 25% | 10 years linear |
| Ecosystem Fund | 54M | 15% | 5 years, quarterly |
| Private Sale | 54M | 15% | 2 years, 6 month cliff |
| Public Sale | 18M | 5% | No vesting |
| Initial Validators | 36M | 10% | 2 years linear |
| Liquidity & Market Making | 36M | 10% | Unlocked |
| Airdrops & Incentives | 36M | 10% | 3 years |

### Emission Schedule (360M LUX)

Remaining 360M LUX minted over time for staking rewards:

```python
def annual_emission(year):
    if year <= 1:
        return 50_000_000  # 50M first year
    elif year <= 5:
        return 40_000_000  # 40M years 2-5
    elif year <= 10:
        return 20_000_000  # 20M years 6-10
    else:
        return 10_000_000  # 10M/year until cap
```

## Staking Economics

### Validator Requirements

| Chain | Minimum Stake | Maximum Stake |
|-------|--------------|---------------|
| Primary Network | 2,000 LUX | No limit |
| M-Chain Validator | Top 100 by stake | No limit |
| Z-Chain Validator | 100,000 LUX | No limit |

### Staking Rewards

Annual Percentage Yield (APY) based on total staked:

```python
def calculate_apy(total_staked_percentage):
    if total_staked_percentage < 0.5:
        return 0.12  # 12% APY
    elif total_staked_percentage < 0.6:
        return 0.10  # 10% APY
    elif total_staked_percentage < 0.7:
        return 0.08  # 8% APY
    elif total_staked_percentage < 0.8:
        return 0.06  # 6% APY
    else:
        return 0.05  # 5% APY minimum
```

### Delegation

- Minimum delegation: 25 LUX
- Maximum delegation ratio: 5:1 (5x validator's self-stake)
- Delegation fee: 2-20% (set by validator)

## Fee Structure

### Transaction Fees

| Chain | Base Fee | Dynamic Fee | Fee Token |
|-------|----------|-------------|-----------|
| P-Chain | 0.001 LUX | No | LUX |
| X-Chain | 0.001 LUX | No | LUX |
| C-Chain | 25 nLUX/gas | EIP-1559 | LUX |
| M-Chain | 0.3% of value | No | LUX |
| Z-Chain | 0.01 LUX + proof cost | Yes | LUX |

### Fee Distribution

```python
def distribute_fees(chain, total_fees):
    if chain in ['P', 'X', 'C']:
        # Primary network fees
        burn_amount = total_fees * 0.50      # 50% burned
        validator_reward = total_fees * 0.50  # 50% to block producer
        
    elif chain == 'M':
        # M-Chain bridge fees
        burn_amount = total_fees * 0.20           # 20% burned
        mpc_validators = total_fees * 0.60       # 60% to MPC validators
        insurance_fund = total_fees * 0.10       # 10% to insurance
        treasury = total_fees * 0.10             # 10% to treasury
        
    elif chain == 'Z':
        # Z-Chain privacy fees
        burn_amount = total_fees * 0.30          # 30% burned
        zk_validators = total_fees * 0.50        # 50% to ZK validators
        prover_rewards = total_fees * 0.20       # 20% to proof generators
```

## Special Economics

### X-Chain Exchange Economics

Trading fees and incentives:

```python
class ExchangeFees:
    maker_rebate = -0.02%    # Makers receive rebate
    taker_fee = 0.04%        # Takers pay fee
    
    def distribute(self, net_fees):
        validators = net_fees * 0.25     # 25% to validators
        burn = net_fees * 0.50          # 50% burned
        insurance = net_fees * 0.15     # 15% to insurance fund
        development = net_fees * 0.10   # 10% to development
```

### M-Chain Bridge Economics

Bridge fees and insurance:

```python
class BridgeEconomics:
    base_fee = 0.3%  # Of transferred value
    
    # Insurance fund parameters
    target_insurance_ratio = 0.10  # 10% of TVL
    max_payout_ratio = 0.50       # Max 50% per incident
    
    # Slashing conditions
    def slash_validator(self, validator, severity):
        if severity == "minor":
            slash_amount = validator.stake * 0.01  # 1%
        elif severity == "major":
            slash_amount = validator.stake * 0.10  # 10%
        elif severity == "critical":
            slash_amount = validator.stake * 0.50  # 50%
```

### Z-Chain Privacy Economics

ZK proof generation incentives:

```python
class ZKEconomics:
    base_proof_fee = 0.01  # LUX per proof
    
    # Proof complexity multipliers
    complexity_fees = {
        "simple_transfer": 1.0,
        "complex_circuit": 2.5,
        "fhe_operation": 5.0,
        "ai_attestation": 10.0,
    }
    
    # Validator hardware requirements affect rewards
    hardware_multipliers = {
        "basic_gpu": 1.0,
        "high_end_gpu": 1.5,
        "tee_enabled": 2.0,
    }
```

## Governance

### Voting Power

Voting weight calculation:

```python
def calculate_voting_power(address):
    staked_lux = get_staked_amount(address)
    delegated_lux = get_delegated_amount(address)
    
    # Direct stake counts 100%
    # Delegated stake counts 10%
    voting_power = staked_lux + (delegated_lux * 0.1)
    
    # Time multiplier (up to 2x for long-term stakers)
    time_multiplier = min(2.0, 1.0 + staking_years(address) * 0.1)
    
    return voting_power * time_multiplier
```

### Proposal Thresholds

| Action | Required LUX | Quorum | Approval |
|--------|--------------|---------|----------|
| Parameter Change | 100,000 | 10% | 51% |
| Protocol Upgrade | 1,000,000 | 20% | 67% |
| Emergency Action | 5,000,000 | 30% | 80% |

## Economic Security

### Slashing Conditions

| Violation | Penalty |
|-----------|---------|
| Downtime (>10%) | 0.1% of stake |
| Double signing | 5% of stake |
| Invalid MPC signature | 10% of stake |
| Malicious bridge operation | 50% of stake |

### Insurance Fund

- Target size: 10% of Total Value Locked (TVL)
- Funded by: Bridge fees, slashing penalties
- Maximum payout: 50% per incident
- Replenishment: Priority from future fees

## Token Burns

Deflationary mechanisms:

1. **Transaction fees**: 50% of base fees burned
2. **Exchange fees**: 50% of net trading fees burned
3. **Inactive stakes**: Unclaimed rewards after 1 year
4. **Slashing**: 50% of slashed tokens burned

## Future Adjustments

Parameters subject to governance:

- Staking requirements
- Fee percentages
- Reward rates
- Burn rates
- Insurance fund targets

Parameters fixed:

- Total supply cap (720M LUX)
- Initial distribution
- Minimum staking periods

## Implementation

Smart contracts controlling tokenomics:

- `StakingRewards.sol`: Handles staking and delegation
- `FeeController.sol`: Manages fee distribution
- `Treasury.sol`: Controls ecosystem funds
- `Insurance.sol`: Bridge insurance fund
- `Governance.sol`: On-chain governance

## Economic Modeling

Based on modeling with various scenarios:

- **Target staking ratio**: 60-70% of circulating supply
- **Projected APY**: 5-8% at maturity
- **Fee revenue**: $10-50M annually at scale
- **Burn rate**: 1-2% of supply annually

## Security Considerations

1. **Stake Concentration**: Delegation limits prevent centralization
2. **Economic Attacks**: High capital requirements for attacks
3. **Insurance Solvency**: Conservative payout limits
4. **Governance Capture**: Time-locked voting power

## Copyright

Copyright and related rights waived via CC0.