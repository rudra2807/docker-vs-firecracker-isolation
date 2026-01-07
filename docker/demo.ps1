Write-Host "== Docker: Kernel identity =="
docker run --rm ubuntu:22.04 uname -a

Write-Host ""
Write-Host "== Docker: Shared kernel modules (host view) =="
docker run --rm ubuntu:22.04 sh -c "cat /proc/modules | head"

Write-Host ""
Write-Host "== Docker: Capabilities (default, non-privileged) =="
docker run --rm ubuntu:22.04 sh -c "apt-get update >/dev/null && apt-get install -y libcap2-bin >/dev/null && capsh --print | grep cap_sys_admin || true"

Write-Host ""
Write-Host "Note:"
Write-Host "- Containers share the host kernel"
Write-Host "- Isolation depends on kernel configuration and capabilities"
Write-Host "- Isolation relies on configuration rather than a hard boundary"
