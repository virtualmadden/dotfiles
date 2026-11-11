#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles
git -C "$DIR" config core.hooksPath .githooks
exec sudo darwin-rebuild switch --flake ~/.dotfiles#mac
