# Contributing to andamio-access-token

Thank you for your interest in contributing to the Andamio Protocol.

## Prerequisites

- GHC 9.6.x
- Cabal 3.8+

## Getting Started

```bash
cabal build all
cabal test all
```

To regenerate the compiled blueprint:

```bash
cabal run write-blueprints
```

## How to Contribute

### Reporting Bugs

Open a [GitHub Issue](https://github.com/Andamio-Platform/access-token/issues) with:
- A clear description of the problem
- Steps to reproduce
- Expected vs. actual behavior

### Suggesting Changes

Open an issue before writing code for non-trivial changes. This avoids wasted effort if the direction doesn't align with the project roadmap.

### Submitting a Pull Request

1. Fork the repository and create a branch from `main`
2. Make your changes with clear, focused commits
3. Ensure `cabal test all` passes with no failures
4. Open a PR against `main` with a description of what changed and why

## Security

Please do **not** open public issues for security vulnerabilities. See [SECURITY.md](SECURITY.md) for responsible disclosure instructions.

## License

By contributing, you agree that your contributions will be licensed under the [Apache 2.0 License](LICENSE).
