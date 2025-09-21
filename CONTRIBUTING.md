# Contributing to Lean Optics

Thank you for your interest in contributing to Lean Optics! This document provides guidelines for contributing to the project.

## Getting Started

### Prerequisites

- Lean 4 (version 4.8.0 or later)
- Lake package manager
- Git

### Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/fraware/lean-optics.git
   cd lean-optics
   ```

2. **Set up development environment**
   ```bash
   make dev
   ```

3. **Run tests to verify setup**
   ```bash
   make test
   ```

## Development Workflow

### Making Changes

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow the existing code style
   - Add tests for new functionality
   - Update documentation as needed

3. **Test your changes**
   ```bash
   make test-comprehensive
   ```

4. **Run benchmarks** (for performance-critical changes)
   ```bash
   make bench
   ```

### Code Style

- Follow Lean 4 style guidelines
- Use descriptive names for functions and variables
- Add docstrings for public functions
- Keep functions focused and small

### Testing

- Add tests for all new functionality
- Ensure all existing tests pass
- Use the `optic_laws!` tactic where appropriate
- Test edge cases and error conditions

### Documentation

- Update README.md for user-facing changes
- Add docstrings for new public functions
- Update examples in documentation
- Keep the architecture diagram current

## Pull Request Process

1. **Ensure your branch is up to date**
   ```bash
   git fetch origin
   git rebase origin/main
   ```

2. **Run the full test suite**
   ```bash
   make test-comprehensive
   ```

3. **Check for linting issues**
   ```bash
   lake build
   ```

4. **Submit your pull request**
   - Provide a clear description of changes
   - Reference any related issues
   - Include screenshots for UI changes

## Testing Guidelines

### Unit Tests

- Test individual functions and modules
- Use descriptive test names
- Test both success and failure cases
- Verify law preservation for optics

### Integration Tests

- Test composition of different optic types
- Verify performance characteristics
- Test with real-world data structures

### Performance Tests

- Run benchmarks for performance-critical code
- Ensure P95 ≤ 200ms for `optic_laws!` tactic
- Monitor memory usage
- Test determinism across runs

## Release Process

Releases are managed through GitHub Actions:

1. **Create a release branch**
   ```bash
   git checkout -b release/v1.x.x
   ```

2. **Update version numbers**
   - Update `Lakefile.lean`
   - Update `Main.lean`
   - Update documentation

3. **Run release preparation**
   ```bash
   make release-dry-run
   ```

4. **Create GitHub release**
   - Tag the release
   - GitHub Actions will build and publish Docker images
   - Update changelog

## Docker Development

For containerized development:

```bash
# Build development image
docker build -t lean-optics:dev .

# Run tests in container
docker run --rm lean-optics:dev test

# Interactive development
docker run -it --rm -v $(pwd):/opt/lean-optics lean-optics:dev bash
```

## Reporting Issues

When reporting issues, please include:

- Lean 4 version
- Operating system
- Steps to reproduce
- Expected vs actual behavior
- Relevant error messages

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold this code.

## Questions?

Feel free to open an issue for questions or discussions about the project.
