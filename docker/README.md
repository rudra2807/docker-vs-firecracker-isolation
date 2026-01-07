# Docker: Shared Kernel Isolation Model

This section demonstrates Docker’s isolation model using **safe, non-destructive**
commands.

The goal here is not to criticize Docker. It is to make one architectural point
clear: **Docker containers share the host kernel** and rely on kernel mechanisms
(namespaces, cgroups, and capabilities) for isolation.

No privileged containers. No exploits. No CVEs.

---

## What this demo shows

- Containers run on the **same kernel as the host**
- Kernel state is shared and visible from inside the container
- Isolation is enforced by configuration rather than a hard boundary

These behaviors are expected and by design.

---

## How to run

Make sure Docker Desktop is running, then run one of the following from the
repository root.

### On Linux / macOS (bash)

```bash
./docker/demo.sh
```

### On Windows (PowerShell)

```bash
./docker/demo.ps1
```
---
## Expected observations

### Kernel identity
Running `uname -a` inside the container reports the **same kernel version** as the host system. Containers do not boot their own kernel.

### Shared kernel state
Interfaces like `/proc` expose live kernel state that belongs to the host,
such as loaded kernel modules.

### Capability-based isolation
Linux capabilities demonstrate that container isolation can change based on
runtime configuration. By default, Docker drops dangerous capabilities, but this
is a policy decision rather than a hardware boundary.

---

## Why this matters
Docker’s shared-kernel model enables fast startup times and low overhead, which works well for trusted workloads and development environments.

Because the kernel is shared, isolation ultimately depends on kernel correctness and runtime configuration. This becomes an important consideration for multi-tenant or untrusted workloads, which is where stronger isolation models, such as microVMs, are often used.