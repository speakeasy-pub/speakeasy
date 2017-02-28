#!/bin/sh
set -ex

# Get version
dart --version

# Get dependencies
pub install
