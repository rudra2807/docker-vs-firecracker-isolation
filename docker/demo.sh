#!/usr/bin/env bash
set -euo pipefail

echo "== Docker: Kernel identity =="
docker run --rm ubuntu:22.04 uname -a

echo
echo "== Docker: Shared kernel modules (host view) =="
docker run --rm ubuntu:22.04 sh -c "cat /proc/modules | head"

echo
echo "== Docker: Capabilities (default, non-privileged) =="
docker run --rm ubuntu:22.04 sh -c "
  apt-get update >/dev/null &&
  apt-get install -y libcap2-bin >/dev/null &&
  capsh --print | grep cap_sys_admin || true
"

echo
echo "Note:"
echo "- Containers share the host kernel"
echo "- Isolation depends on kernel configuration and capabilities"
echo "- Isolation relies on configuration rather than a hard boundary"