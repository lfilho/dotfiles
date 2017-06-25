#!/usr/bin/env bash
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  # The following is a caveat: we're forcing a zsh command (with the shebang),
  # as we can't simulate a login shell on Travis running the script (not that I'm aware of).
  # Ideally, after the chsh command (during the installation process)
  # we would enter a new shell session, now with zsh as our default shell,
  # and the execute the test script... ¯\_(ツ)_/¯
  ./test/install-smoke-test.sh
else
  docker run yadr bash -c "~/.yadr/test/install-smoke-test.sh"
fi
