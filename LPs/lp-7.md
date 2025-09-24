---
lp: 7
title: VM SDK Specification
description: Defines the Virtual Machine SDK for Lux.
author: Lux Network Team (@luxdefi)
discussions-to: https://github.com/luxfi/lps/discussions
status: Draft
type: Standards Track
category: Core
created: 2025-01-23
---

## Abstract

This LP defines the Virtual Machine SDK for Lux (in the vmsdk repo), which allows developers to create new blockchain VMs that run on Lux subnets.

## Specification

*(This LP will specify the interface a VM must implement (for example, methods for block validation, state management, and consensus hooks), enabling it to integrate with the consensus layer.)*

## Rationale

By providing an SDK spec, Lux invites innovation: teams could develop specialized chains (subnets) for particular use cases, all while conforming to a common framework.

## Motivation

A standardized VM SDK removes ambiguity for VM authors, accelerates development of specialized subnets, and ensures consistent integration with Lux consensus and tooling.

## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).
## Backwards Compatibility

Additive and non‑breaking; existing consumers continue to work. Adoption is opt‑in.

## Security Considerations

Apply appropriate validation, authentication, and resource‑limiting to prevent abuse; follow cryptographic best practices where applicable.
