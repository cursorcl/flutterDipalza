#!/usr/bin/env bash
set -euo pipefail

VERSION="$1"
BUILD_NUMBER="${GITHUB_RUN_NUMBER:-1}"

sed -i.bak "s/^version: .*/version: ${VERSION}+${BUILD_NUMBER}/" pubspec.yaml
rm -f pubspec.yaml.bak

echo "pubspec.yaml version set to ${VERSION}+${BUILD_NUMBER}"
