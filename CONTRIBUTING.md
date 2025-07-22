# Contributing to Lux Improvement Proposals (LIPs)

Thank you for your interest in contributing to the Lux Network through the LIP process! This document outlines the terms and guidelines for contributing.

## Terms of Contribution

By contributing to this repository, you agree to the following terms:

### 1. Intellectual Property Rights

- All contributions are considered public domain.
- You waive all copyright and related rights to your contributions via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
- You represent that you have the right to waive such rights.
- You understand that your contributions will be permanently public and may be redistributed.

### 2. Code of Conduct

Contributors must:
- Be respectful and professional in all interactions
- Focus on what is best for the Lux Network and community
- Accept constructive criticism gracefully
- Show empathy towards other community members

Contributors must not:
- Use inappropriate language or imagery
- Engage in personal attacks or harassment
- Publish others' private information without permission
- Engage in any conduct that could be considered inappropriate in a professional setting

### 3. Contribution Guidelines

#### Before You Begin

1. **Search existing LIPs**: Ensure your idea hasn't already been proposed or implemented.
2. **Start a discussion**: Post your idea in the GitHub Discussions "Ideas" category first.
3. **Get feedback**: Gauge community interest before drafting a full LIP.

#### Writing Your LIP

1. **Use the template**: Start with the [LIP template](./LIPs/TEMPLATE.md).
2. **Be clear and concise**: Technical specifications should be detailed but accessible.
3. **Focus on one idea**: Each LIP should address a single, well-defined improvement.
4. **Consider all aspects**: Address security, backwards compatibility, and economic impacts.

#### Special Considerations for LRCs (Application Standards)

If you're proposing an application-layer standard (token interface, wallet standard, etc.):

1. **Set category to LRC**: In the template, use `category: LRC` for Standards Track proposals.
2. **Include interoperability focus**: Show how multiple implementations can work together.
3. **Provide reference implementations**: Include at least one complete implementation.
4. **Test with real applications**: Demonstrate usage in actual dApps or wallets.
5. **Use LRC numbering in title**: E.g., "LRC-20 Fungible Token Standard"

#### Submission Process

1. **Fork the repository**: Create your own fork of the LIP repository.
2. **Create a branch**: Name it `lip-draft-your-title`.
3. **Add your LIP**: Create a new file `LIPs/lip-draft.md` with your proposal.
4. **Submit a PR**: The PR number will become your LIP number once merged.

#### After Submission

1. **Engage with feedback**: Respond to comments and suggestions on your PR.
2. **Make revisions**: Update your LIP based on community feedback.
3. **Shepherd discussion**: Once merged, actively participate in the GitHub Discussion.

### 4. Standards and Formatting

#### Markdown Style

- Use [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/).
- Keep lines under 120 characters when possible.
- Use proper heading hierarchy (don't skip levels).
- Include a table of contents for long documents.

#### Code Examples

- Use syntax highlighting with language specifiers.
- Keep examples concise and relevant.
- Include comments explaining complex logic.
- Test all code examples before submission.

#### References

- Link to relevant external resources.
- Cite sources for technical claims.
- Reference related LIPs where applicable.

### 5. Review Process

LIP maintainers will review submissions for:

- **Completeness**: All required sections are present and thorough.
- **Clarity**: The proposal is well-written and understandable.
- **Technical Merit**: The proposal is technically sound.
- **Alignment**: The proposal aligns with Lux Network goals and values.

### 6. Licensing

By submitting an LIP, you agree that:

- Your contribution is original work or you have rights to submit it.
- Your contribution is licensed under [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/).
- You waive all copyright and related rights.

### 7. Recognition

Contributors will be:
- Listed as authors on their LIPs
- Acknowledged in the LIP repository
- Eligible for community recognition programs
- Considered for the Lux Weights rewards system (see LIP-1)

## Getting Help

If you need assistance:

- **Discord**: Join our [Discord server](https://discord.gg/lux) and ask in #lip-help
- **Forum**: Post questions in the [Lux Community Forum](https://forum.lux.network)
- **GitHub**: Open an issue for technical problems with the repository

## Maintenance

### For LIP Authors

- You are responsible for maintaining your LIP while it's in `Proposed` or `Implementable` status.
- Review and approve/request changes to PRs that modify your LIP.
- Keep the community updated on implementation progress.

### For Maintainers

- Merge well-formatted, coherent proposals regardless of personal opinion on merit.
- Ensure discussions remain respectful and productive.
- Help authors improve their proposals through constructive feedback.

## Questions?

If you have questions about the contribution process, please:
1. Check the [LIP README](./README.md)
2. Search existing [GitHub Discussions](https://github.com/luxfi/lips/discussions)
3. Ask in our [Discord](https://discord.gg/lux) #lip-help channel

Thank you for contributing to the Lux Network!