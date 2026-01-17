#!/usr/bin/env bash
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  cd ~/.yadr || exit 1
  ./install.sh
else
  docker build -t yadr .
fi
