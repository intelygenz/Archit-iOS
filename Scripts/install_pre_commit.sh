#!/bin/sh
set -eu

echo "Installing pre-commit..."
ln -s ../../Scripts/pre_commit.sh .git/hooks/pre-commit
echo "Pre-commit installed!"
