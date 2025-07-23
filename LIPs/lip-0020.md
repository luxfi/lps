---
lip: 20
title: LRC-20 Fungible Token Standard
description: A standard interface for fungible tokens on Lux Network
author: Lux Team
discussions-to: https://github.com/luxfi/lips/discussions/20
status: Draft
type: Standards Track
category: LRC
created: 2025-07-19
---

## Abstract

This standard defines a common interface for fungible tokens on the Lux Network. It provides basic functionality to transfer tokens, approve spending by third parties, and query token balances. This standard is inspired by and compatible with Ethereum's ERC-20 standard, adapted for Lux's multi-chain architecture.

## Motivation

A standard interface allows any tokens on Lux to be re-used by other applications: from wallets to decentralized exchanges. This standard provides basic functionality to transfer tokens and allow tokens to be spent by another on-chain third party. By establishing a common interface, we enable:

- Wallet integration without custom code for each token
- Decentralized exchange listings without manual integration
- Block explorers to display token information consistently
- Other contracts to interact with any LRC-20 token predictably

## Specification

### Token Interface

```solidity
interface ILRC20 {
    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Required Methods
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    // Optional Methods
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
```

### Methods

#### totalSupply

Returns the total token supply.

```solidity
function totalSupply() external view returns (uint256)
```

#### balanceOf

Returns the account balance of another account with address `account`.

```solidity
function balanceOf(address account) external view returns (uint256)
```

#### transfer

Transfers `amount` tokens to address `to`, and MUST fire the `Transfer` event. The function SHOULD `revert` if the message caller's account balance does not have enough tokens to spend.

```solidity
function transfer(address to, uint256 amount) external returns (bool)
```

#### approve

Allows `spender` to withdraw from your account multiple times, up to the `amount`. If this function is called again it overwrites the current allowance with `amount`.

```solidity
function approve(address spender, uint256 amount) external returns (bool)
```

#### allowance

Returns the amount which `spender` is still allowed to withdraw from `owner`.

```solidity
function allowance(address owner, address spender) external view returns (uint256)
```

#### transferFrom

Transfers `amount` tokens from address `from` to address `to`, and MUST fire the `Transfer` event.

```solidity
function transferFrom(address from, address to, uint256 amount) external returns (bool)
```

### Events

#### Transfer

MUST trigger when tokens are transferred, including zero value transfers.

```solidity
event Transfer(address indexed from, address indexed to, uint256 value)
```

#### Approval

MUST trigger on any successful call to `approve(address spender, uint256 amount)`.

```solidity
event Approval(address indexed owner, address indexed spender, uint256 value)
```

## Rationale

This standard is intentionally designed to be compatible with Ethereum's ERC-20 standard to maximize interoperability and minimize the learning curve for developers. The main considerations were:

- **Simplicity**: Keep the interface minimal and clear
- **Compatibility**: Maintain compatibility with existing tools and infrastructure
- **Security**: Follow established patterns that have been battle-tested
- **Flexibility**: Allow optional extensions while maintaining a core standard

## Backwards Compatibility

This standard is fully compatible with ERC-20 tokens deployed on Lux C-Chain. Existing ERC-20 tokens can be considered compliant with LRC-20 without any changes.

## Test Cases

### Transfer Tests

```javascript
// Test successful transfer
const result = await token.transfer(recipient, 100);
assert(result === true);
assert(await token.balanceOf(recipient) === 100);

// Test transfer exceeding balance
await expect(token.transfer(recipient, 1000000)).to.be.reverted;
```

### Approval Tests

```javascript
// Test approval
await token.approve(spender, 100);
assert(await token.allowance(owner, spender) === 100);

// Test transferFrom
await token.connect(spender).transferFrom(owner, recipient, 50);
assert(await token.balanceOf(recipient) === 50);
assert(await token.allowance(owner, spender) === 50);
```

## Reference Implementation

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LRC20 is ILRC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    string public name;
    string public symbol;
    uint8 public decimals = 18;

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        _totalSupply = _initialSupply;
        _balances[msg.sender] = _initialSupply;
        emit Transfer(address(0), msg.sender, _initialSupply);
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(_balances[from] >= amount, "Insufficient balance");
        require(_allowances[from][msg.sender] >= amount, "Insufficient allowance");
        
        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;
        
        emit Transfer(from, to, amount);
        return true;
    }
}
```

## Security Considerations

### Race Condition in Approval

The `approve` method is subject to a race condition. If a user calls `approve` twice, with different values, an attacker may be able to spend both amounts. To mitigate this:

1. Always set approval to 0 before setting it to a new value
2. Use `increaseAllowance` and `decreaseAllowance` functions (extensions to this standard)

### Integer Overflow/Underflow

Implementations should use Solidity 0.8.0 or higher which has built-in overflow protection, or use a safe math library for earlier versions.

### Transfer to Zero Address

Implementations should prevent transfers to the zero address (0x0) to avoid accidental token burns.

### Reentrancy

While the standard interface doesn't include external calls, implementations that do (e.g., in extensions) should guard against reentrancy attacks.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).