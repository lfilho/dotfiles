#!/usr/bin/env bash
if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  cd ~/.yadr
  rake install
else
  docker build -t yadr .
fi
