# GitHub Configuration

This directory contains GitHub-specific configuration files.

## Workflows

### CI Workflow (`.github/workflows/ci.yml`)

Automated testing workflow that runs on every push and pull request to `main` branch.

**Test Matrix:**
- **macOS 14**: Tests on macOS Sonoma with native installation
- **Ubuntu 22.04**: Tests via Docker container

**Environment:**
- Uses `CI=true` to install minimal packages from `test/Brewfile_ci`
- Runs smoke tests to verify installation success

**Triggers:**
- Push to `main`
- Pull requests to `main`
- Manual dispatch via GitHub Actions UI

**Viewing Results:**
1. Go to your repository on GitHub
2. Click on "Actions" tab
3. View workflow runs and logs

## Setup Requirements

No additional setup needed! GitHub Actions works automatically once you push this repository to GitHub.

**Badge (optional):** Add this to your README.md to show build status:
```markdown
![CI](https://github.com/YOUR_USERNAME/dotfiles/workflows/CI/badge.svg)
```

## Local Testing

You can test locally using the same commands the CI uses:

```bash
# Test with CI mode (minimal packages)
cd ~/.yadr
CI=true ./install.sh

# Test with Docker (Linux)
docker build --build-arg CI=true -t yadr-test .
docker run -it yadr-test

# Run smoke tests
./test/install-smoke-test.sh
```

## Troubleshooting

**If macOS job fails:**
- Check if homebrew installation succeeded
- Verify all paths are correct (moved to `~/.yadr`)
- Check smoke test requirements in `test/install-smoke-test.sh`

**If Linux job fails:**
- Check Docker build logs for errors
- Verify `Dockerfile` is valid
- Ensure all required packages are in `test/Brewfile_ci`

**Workflow not running:**
- Ensure you've pushed to `main` branch
- Check branch protection rules don't block Actions
- Verify Actions are enabled in repository settings

