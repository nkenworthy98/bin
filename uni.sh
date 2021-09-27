#!/usr/bin/env bash
# Update Nitter Instances
set -euo pipefail

curl https://raw.githubusercontent.com/wiki/zedeus/nitter/Instances.md > txt-files/nitter.md
