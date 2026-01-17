# Tests

Travis CI is configured for automated testing on multiple platforms:

## Test Matrix

The installation is tested on:
- **macOS**: Xcode 14.2 (macOS 12 Monterey)
- **Linux**: Ubuntu 22.04 Jammy (via Docker)

## Test Flow

1. **before_install** (`travis-before-install.sh`): Prepares the environment
   - macOS: Moves the build directory to `~/.yadr`
   - Linux: Installs Docker Compose

2. **install** (`travis-install.sh`): Runs the installation
   - macOS: Executes `./install.sh` directly
   - Linux: Builds Docker image with `docker build -t yadr .`

3. **script** (`travis-test-script.sh`): Runs smoke tests
   - Executes `install-smoke-test.sh` which verifies:
     - Shell changed to zsh
     - Essential packages installed (nvim, git, fzf)

## Files

- **Brewfile_ci**: Minimal package list for faster CI builds (used when `CI=true`)
- **install-smoke-test.sh**: Basic smoke tests to verify successful installation
- **travis-*.sh**: Travis CI lifecycle scripts

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
