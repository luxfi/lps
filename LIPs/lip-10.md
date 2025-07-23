---
lip: 10
title: P-Chain (Platform Chain) Specification
description: Defines the Platform Chain for network coordination, staking, and governance
author: Lux Network Team (@luxdefi)
discussions-to: https://forum.lux.network/lip-10
status: Draft
type: Standards Track
category: Core
created: 2025-01-23
requires: 0, 1, 4
---

## Abstract

This LIP specifies the P-Chain (Platform Chain), the governance and coordination backbone of the Lux Network. The P-Chain manages validators, handles staking operations, coordinates subnet creation, and serves as the platform for network-wide governance decisions. It implements Snowman consensus for linear chain operation optimized for platform management.

## Motivation

The P-Chain serves as the critical coordination layer for the Lux Network by:

1. **Validator Management**: Tracking and coordinating all network validators
2. **Staking Operations**: Handling LUX token staking and delegation
3. **Subnet Coordination**: Managing creation and lifecycle of subnets
4. **Network Governance**: Executing on-chain governance decisions
5. **Cross-Chain Coordination**: Maintaining validator sets for specialized chains

## Specification

### Chain Architecture

```
┌─────────────────────────────────────────────────┐
│                   P-Chain                        │
├─────────────────────────────────────────────────┤
│              Validator Registry                  │
│         (Track all network validators)           │
├─────────────────────────────────────────────────┤
│              Staking Manager                     │
│      (Handle staking and delegations)            │
├─────────────────────────────────────────────────┤
│               Subnet Factory                     │
│        (Create and manage subnets)               │
├─────────────────────────────────────────────────┤
│            Governance Module                     │
│         (Execute network upgrades)               │
└─────────────────────────────────────────────────┘
```

### Core Components

#### Validator Management

```solidity
struct Validator {
    bytes32 nodeID;           // Unique node identifier
    address owner;            // Validator owner address
    uint256 stake;           // Total staked amount
    uint256 delegatedStake;  // Total delegated to this validator
    uint256 startTime;       // When validation started
    uint256 endTime;         // When validation ends
    uint256 uptime;          // Uptime percentage (basis points)
    bool isActive;           // Current validation status
    ValidatorMetadata metadata;
}

struct ValidatorMetadata {
    string location;         // Geographic location
    uint256 delegationFee;   // Fee charged to delegators (basis points)
    uint256 minDelegation;   // Minimum delegation accepted
    bytes publicKey;         // BLS public key for consensus
}
```

#### Staking Operations

```solidity
interface IPChainStaking {
    // Validator operations
    function addValidator(
        bytes32 nodeID,
        uint256 stake,
        uint256 startTime,
        uint256 endTime,
        uint256 delegationFee
    ) external returns (bytes32 validatorID);
    
    function removeValidator(bytes32 validatorID) external;
    
    // Delegation operations
    function delegate(
        bytes32 validatorID,
        uint256 amount,
        uint256 startTime,
        uint256 endTime
    ) external returns (bytes32 delegationID);
    
    function undelegate(bytes32 delegationID) external;
    
    // Reward operations
    function claimRewards(address staker) external returns (uint256);
    
    // View functions
    function getValidatorInfo(bytes32 validatorID) external view returns (Validator memory);
    function getPendingRewards(address staker) external view returns (uint256);
    function getTotalStaked() external view returns (uint256);
}
```

### Subnet Management

#### Subnet Creation

```solidity
struct Subnet {
    bytes32 subnetID;
    address creator;
    SubnetConfig config;
    bytes32[] validators;    // Validator set for this subnet
    uint256 createdAt;
    bool isActive;
}

struct SubnetConfig {
    uint256 minValidators;   // Minimum validator count
    uint256 minStake;        // Minimum stake per validator
    uint256 maxValidators;   // Maximum validator count
    bytes vmID;              // Virtual Machine ID
    bytes genesis;           // Genesis configuration
    SubnetParameters params;
}

interface ISubnetFactory {
    function createSubnet(
        SubnetConfig memory config,
        bytes32[] memory initialValidators
    ) external returns (bytes32 subnetID);
    
    function addSubnetValidator(
        bytes32 subnetID,
        bytes32 validatorID,
        uint256 weight
    ) external;
    
    function removeSubnetValidator(
        bytes32 subnetID,
        bytes32 validatorID
    ) external;
}
```

### Governance System

#### Proposal Structure

```solidity
struct Proposal {
    bytes32 proposalID;
    address proposer;
    ProposalType proposalType;
    bytes data;              // Encoded proposal data
    uint256 startTime;
    uint256 endTime;
    uint256 yesVotes;
    uint256 noVotes;
    ProposalStatus status;
}

enum ProposalType {
    PARAMETER_CHANGE,        // Change network parameters
    UPGRADE_PROPOSAL,        // Upgrade network software
    EMERGENCY_ACTION,        // Emergency protocol action
    ECONOMIC_POLICY,         // Change economic parameters
    VALIDATOR_SET_CHANGE     // Modify validator requirements
}

enum ProposalStatus {
    PENDING,
    ACTIVE,
    PASSED,
    REJECTED,
    EXECUTED,
    CANCELLED
}
```

#### Voting Mechanism

```solidity
interface IGovernance {
    function createProposal(
        ProposalType proposalType,
        bytes memory data,
        string memory description
    ) external returns (bytes32 proposalID);
    
    function vote(
        bytes32 proposalID,
        bool support,
        uint256 weight  // Voting weight based on stake
    ) external;
    
    function executeProposal(bytes32 proposalID) external;
    
    // View functions
    function getProposal(bytes32 proposalID) external view returns (Proposal memory);
    function getVotingPower(address voter) external view returns (uint256);
}
```

### Consensus Parameters

The P-Chain uses Snowman consensus with the following parameters:

```yaml
consensus:
  type: snowman
  parameters:
    sampleSize: 20          # Number of validators to query
    quorumSize: 14          # Minimum responses for quorum
    preferenceStrength: 5   # Consecutive rounds for finalization
    maxOutstanding: 256     # Maximum concurrent queries
    maxProcessing: 8        # Maximum processing blocks
```

### Transaction Types

#### Native P-Chain Transactions

1. **AddValidatorTx**: Add a new validator to the network
2. **AddDelegatorTx**: Delegate stake to a validator
3. **AddSubnetValidatorTx**: Add validator to subnet
4. **CreateSubnetTx**: Create a new subnet
5. **CreateChainTx**: Create a new blockchain in subnet
6. **ImportTx**: Import LUX from another chain
7. **ExportTx**: Export LUX to another chain

### Cross-Chain Integration

#### Validator Set Synchronization

```solidity
interface IValidatorSync {
    // Get validator set for specialized chains
    function getMChainValidators() external view returns (bytes32[] memory);
    function getZChainValidators() external view returns (bytes32[] memory);
    
    // Update validator sets
    function updateSpecializedChainValidator(
        SpecializedChain chain,
        bytes32 validatorID,
        bool isActive
    ) external;
}

enum SpecializedChain {
    M_CHAIN,
    Z_CHAIN
}
```

### Economic Parameters

#### Staking Requirements

| Parameter | Value | Description |
|-----------|-------|-------------|
| Minimum Validator Stake | 2,000 LUX | Minimum to become a validator |
| Maximum Validator Stake | 3,000,000 LUX | Maximum stake per validator |
| Minimum Delegation | 25 LUX | Minimum delegation amount |
| Maximum Delegation Ratio | 5:1 | Max delegated vs self-stake |
| Minimum Staking Duration | 2 weeks | Minimum staking period |
| Maximum Staking Duration | 52 weeks | Maximum staking period |

#### Reward Distribution

```python
def calculate_validator_reward(validator, total_stake, emission_rate):
    # Base reward from emission
    stake_weight = validator.stake / total_stake
    base_reward = emission_rate * stake_weight
    
    # Uptime bonus/penalty
    uptime_multiplier = validator.uptime / 10000  # Convert from basis points
    
    # Delegation fee
    delegation_reward = calculate_delegation_reward(validator)
    validator_fee = delegation_reward * (validator.delegationFee / 10000)
    
    return base_reward * uptime_multiplier + validator_fee
```

### Security Considerations

#### Sybil Resistance
- Minimum stake requirements prevent cheap validator creation
- Uptime requirements ensure active participation
- Slashing for misbehavior (future implementation)

#### Governance Security
- High quorum requirements for critical changes
- Time delays for proposal execution
- Emergency pause mechanisms for critical issues

#### Validator Security
- Regular key rotation requirements
- Hardware security module support
- Distributed infrastructure recommendations

## Rationale

### Design Decisions

1. **Linear Chain**: Snowman consensus provides finality for platform operations
2. **Stake-Based Governance**: Aligns voting power with network investment
3. **Flexible Subnets**: Allows customized blockchain creation
4. **Cross-Chain Coordination**: Maintains specialized chain validator sets
5. **Economic Incentives**: Rewards long-term staking and high uptime

### Trade-offs

1. **Complexity**: Platform operations add complexity vs pure transaction chains
2. **Centralization Risk**: Large validators have more influence
3. **Governance Speed**: Democratic process can slow critical updates

## Backwards Compatibility

The P-Chain maintains compatibility with:
- Existing Avalanche P-Chain transactions
- Current staking mechanisms
- Subnet creation processes

New features are added via soft forks when possible.

## Test Cases

### Validator Addition Test
```python
def test_add_validator():
    # Create validator
    tx = AddValidatorTx(
        nodeID=generate_node_id(),
        stake=2000 * 10**9,  # 2000 LUX
        startTime=now() + 86400,  # Start tomorrow
        endTime=now() + 86400 * 30,  # 30 days
        delegationFee=200  # 2%
    )
    
    # Submit transaction
    result = p_chain.submit_tx(tx)
    assert result.status == "accepted"
    
    # Verify validator added
    validator = p_chain.get_validator(tx.nodeID)
    assert validator.stake == 2000 * 10**9
    assert validator.isActive == False  # Not active until startTime
```

### Governance Test
```python
def test_governance_proposal():
    # Create proposal to change minimum stake
    proposal = create_proposal(
        type=ProposalType.PARAMETER_CHANGE,
        data=encode_parameter_change("minValidatorStake", 3000 * 10**9),
        description="Increase minimum validator stake to 3000 LUX"
    )
    
    # Vote on proposal
    vote(proposal.id, support=True, weight=staking_weight)
    
    # Fast forward to end of voting
    advance_time(VOTING_PERIOD)
    
    # Execute proposal
    execute_proposal(proposal.id)
    
    # Verify parameter changed
    assert p_chain.get_parameter("minValidatorStake") == 3000 * 10**9
```

## Reference Implementation

A reference implementation is available at:
https://github.com/luxdefi/node

Key components:
- P-Chain VM implementation
- Staking manager
- Subnet factory
- Governance module

## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).