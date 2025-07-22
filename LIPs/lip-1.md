---
lip: 1
title: Community Contribution Framework
description: Framework for community contributions to the Lux ecosystem
author: Lux Team
discussions-to: https://github.com/luxfi/lips/discussions/1
status: Review
type: Meta
created: 2024-11-20
---

## Abstract

This LIP proposes a framework to encourage and streamline community contributions to the Lux ecosystem. The goal is to enhance the development of Lux's products and services through community auditing, improvements, help in developing unfinished components, and upgrades to existing platforms. This framework outlines guidelines for contribution, areas of focus, and processes to ensure efficient collaboration between the Lux team and the community.

## Motivation

The Lux ecosystem comprises a comprehensive suite of products and services, some of which are live and others in development. To accelerate growth and innovation, we aim to leverage the power of open-source collaboration. By welcoming community contributions, we can:

- Identify and resolve "unknown unknowns" through diverse perspectives
- Accelerate the development of unfinished components
- Enhance existing platforms with new features and improvements
- Foster a vibrant community around Lux, promoting adoption and innovation

## Specification

### Scope of Contributions

Community members can contribute to the following areas:

1. **Auditing and Security**: Perform code audits to identify vulnerabilities, bugs, or performance issues
2. **Development of Unfinished Components**: Assist in developing projects that are not yet live, such as Lux ZChain and Lux Vote
3. **Upgrades and Enhancements**: Propose and implement new features or improvements to existing platforms like Lux Wallet and Lux Bridge
4. **Cross-Chain Integrations**: Add support for other blockchains (e.g., Solana, Cardano) to enhance interoperability
5. **Documentation and Tutorials**: Improve existing documentation and create tutorials to aid new users and developers

### Repository Setup

To ensure a consistent and organized structure across all Lux repositories:

#### Repository Structure

- **Main Repositories**: Each project within the Lux ecosystem has its own repository under the [Lux GitHub organization](https://github.com/luxfi)
- **Directory Structure**:
  - `src/`: Source code
  - `docs/`: Documentation files, including contribution guidelines and proposals
  - `tests/`: Test suites and related resources
  - `examples/`: Sample code and usage examples
  - `scripts/`: Automation scripts for building, testing, and deployment
  - `proposals/`: For LIPs, located at `docs/contributions/proposals/`

#### Branching Strategy

- `main`: Stable code ready for production
- `develop`: Latest development code, integrating features ready for testing
- Feature Branches: For new features or improvements, named as `feature/short-description`
- Bugfix Branches: For bug fixes, named as `bugfix/issue-number`
- Release Branches: For preparing releases, named as `release/version-number`

### Contribution Guidelines

- **Repository Structure**: All projects will have a standardized repository structure to make navigation and contribution easier
- **Issue Tracking**: Use GitHub Issues to report bugs, suggest enhancements, or propose new features
- **Pull Requests**: Contributors should fork the repository, make changes, and submit a pull request (PR) for review
- **Coding Standards**: Follow the Lux coding standards provided in the `CONTRIBUTING.md` file of each repository
- **Code Reviews**: PRs will be reviewed by maintainers and the community. Feedback should be constructive and respectful
- **Testing**: Ensure that all new code includes appropriate tests and passes existing test suites
- **Licensing**: Contributions must comply with the project's open-source license (BSD License)

### Development Workflow

1. **Fork the Repository**: Create your own fork of the relevant Lux repository
2. **Clone Your Fork**: Clone your fork to your local machine
3. **Set Upstream Remote**: Add the original repository as an upstream remote
4. **Create a Branch**: Create a new branch for your feature or bugfix
5. **Implement Changes**: Write code, add tests, and update documentation as needed
6. **Commit Changes**: Commit your changes with clear and descriptive commit messages
7. **Keep Branch Updated**: Regularly pull changes from the `develop` branch
8. **Push to Your Fork**: Push your branch to your forked repository
9. **Open a Pull Request**: Submit a PR to the `develop` branch of the main repository

### Code Standards

- **Language-Specific Guidelines**:
  - **Go**: Follow the [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
  - **Solidity**: Adhere to the [Solidity Style Guide](https://docs.soliditylang.org/en/v0.8.20/style-guide.html)
  - **TypeScript/JavaScript**: Follow the project's ESLint configuration
- **Linting and Formatting**: Use appropriate tools to ensure code quality
- **Comments and Documentation**: Write clear comments and update relevant documentation

### Recognition and Rewards

To incentivize contributions:

- **Weights System**: Implement the previously defined weights system to reward contributors with LUX tokens based on their contributions
- **Contributor Recognition**: Acknowledge significant contributors in release notes, documentation, and the Lux community platforms
- **Bounties**: Set up a bounty program for high-priority issues or features, offering LUX tokens as rewards

### Communication Channels

- **Discord**: A dedicated [Discord server](https://discord.gg/K746mGXdXr) for real-time communication between contributors and maintainers
- **GitHub Discussions**: Use the Discussions tab in repositories for topic-specific conversations
- **Regular Meetings**: Schedule regular virtual meetings or AMA sessions to discuss progress and address concerns

## Rationale

By establishing a clear and structured framework, we can lower the barrier to entry for community members to contribute effectively. This approach ensures that contributions are meaningful, aligned with Lux's goals, and that contributors feel valued and rewarded.

The framework builds on successful open-source models while adapting to the specific needs of the Lux ecosystem, particularly around blockchain development and cross-chain functionality.

## Backwards Compatibility

This LIP does not introduce any backward compatibility issues as it adds a new process for community contributions without altering existing functionalities.

## Test Cases

As this LIP outlines a framework rather than code changes, test cases are not applicable. However, the success of this framework can be evaluated based on metrics such as:

- Number of community contributions
- Reduction in bugs and vulnerabilities
- Development speed of unfinished components
- Community engagement levels

## Reference Implementation

### Pull Request Template

```markdown
## Description
[Provide a brief description of the changes]

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Enhancement
- [ ] Documentation update
- [ ] Other (please describe)

## Related Issues/LIPs
[Link any related issues or LIPs]

## Checklist
- [ ] I have read the contribution guidelines
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published
```

### Issue Templates

Bug Report and Feature Request templates are available in the repository's `.github/ISSUE_TEMPLATE/` directory.

## Security Considerations

- **Code Quality**: Require thorough code reviews and testing to maintain high code quality
- **Access Control**: Limit write access to main branches to authorized maintainers
- **Disclosure Policies**: Establish responsible disclosure policies for security vulnerabilities
- **Security Audits**: Contributions involving critical code paths will undergo rigorous security audits
- **Compliance Checks**: Ensure that all contributions comply with relevant laws and regulations, especially for financial and security-related projects

## Economic Impact

This framework enables the Weights System for rewarding contributors:
- Contributors earn LUX tokens based on the impact and quality of their contributions
- The reward system incentivizes sustained, high-quality participation
- Economic incentives align community interests with ecosystem growth

## Open Questions

1. What specific metrics should be used to measure contribution impact for the Weights System?
2. How should we handle contributions that span multiple repositories or projects?
3. What governance mechanism should be used to update contribution guidelines?

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).