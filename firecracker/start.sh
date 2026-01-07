#!/bin/bash

# start firecracker
set -euo pipefail

sudo firecracker --no-api --config-file vmconfig.json
