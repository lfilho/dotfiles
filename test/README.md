# Tests

GitHub Actions is configured for automated testing on multiple platforms:

## Test Matrix

The installation is tested on:
- **macOS**: macOS 14 (Sonoma) - `macos-14` runner
- **Linux**: Ubuntu 22.04 (via Docker) - `ubuntu-22.04` runner

## Test Flow

### macOS Job
1. **Checkout**: Clones repository with submodules
2. **Install**: Moves workspace to `~/.yadr` and runs `./install.sh` with `CI=true`
3. **Smoke Tests**: Runs `install-smoke-test.sh` which verifies:
   - Shell changed to zsh
   - Essential packages installed (nvim, git, fzf)

### Linux Job
1. **Checkout**: Clones repository with submodules
2. **Build**: Builds Docker image with `docker build --build-arg CI=true -t yadr .`
3. **Smoke Tests**: Runs tests inside container with `install-smoke-test.sh`

## Files

- **Brewfile_ci**: Minimal package list for faster CI builds (used when `CI=true`)
- **install-smoke-test.sh**: Basic smoke tests to verify successful installation

## GitHub Actions Workflow

The CI workflow is defined in `.github/workflows/ci.yml`:
- Runs on push/PR to `main` branch
- Can be manually triggered via `workflow_dispatch`
- Tests on both macOS 14 and Ubuntu 22.04
- Uses `CI=true` for faster builds with minimal packages

## Local Testing

You can simulate CI builds locally:

```bash
# Test with minimal Brewfile
CI=true ./install.sh

# Test with Docker (Linux)
docker build -t yadr-test .
docker run -it yadr-test

# Run smoke tests
./test/install-smoke-test.sh
```

## Future Improvements

- Add shellcheck validation for all bash scripts
- Test on more OS versions
- Add integration tests for key features
- Test prezto module loading
- Verify neovim plugin installation
