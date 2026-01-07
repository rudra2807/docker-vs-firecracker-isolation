# Docker vs Firecracker: Isolation Demo (WSL2)

This repo is a hands-on, safe comparison of **container isolation** vs **Firecracker microVM isolation**.

Most engineers know Docker starts fast and traditional VMs can take longer to boot. The key difference is **why**, and where Firecracker fits between them:
- **Docker containers share the host kernel** and reuse it directly. There is no firmware or kernel boot process, which is why containers start almost instantly.
- **Traditional virtual machines** boot a full operating system. This includes firmware (BIOS/UEFI), bootloader, kernel initialization, hardware device discovery, and system services. That full boot sequence is why traditional VMs often take minutes to become ready.

## Where Firecracker fits

**Firecracker microVMs** sit between containers and traditional virtual machines.

Firecracker keeps the **hardware-level isolation** of a virtual machine by booting
its own kernel, but it avoids much of the overhead that makes traditional VMs slow.
It does this by:
- using a minimal device model
- skipping legacy hardware and firmware paths
- booting directly into a small, purpose-built Linux kernel

The result is a microVM that starts in seconds while still maintaining a strong
virtualization boundary. This is why Firecracker is used under the hood by
AWS Lambda and AWS Fargate for running untrusted, multi-tenant workloads.


## What you will see

### Docker (Windows Docker Desktop)
- `uname -a` inside a container matches the host kernel (shared kernel model)
- `/proc` and related interfaces reflect host kernel state
- Capabilities show isolation is largely configuration-driven

### Firecracker (Ubuntu on WSL2)
- A microVM boots with its own kernel and root filesystem
- A TAP device provides VM networking
- Optional NAT enables outbound IP connectivity from the guest

## Repo layout

- `docker/`  
  Minimal commands/scripts to demonstrate Docker’s shared-kernel model safely.

- `firecracker/`  
  Scripts to boot a Firecracker microVM and enable networking (TAP + NAT).

- `firecracker-v1.14.0-x86_64.tgz`
Binary to get you set-up with firecracker

## Requirements

### Docker demo
- Docker Desktop on Windows
- Ability to run `docker run` locally

### Firecracker demo
- Ubuntu on WSL2 with Firecracker installed and working
- `iproute2`, `iptables`, `wget`
- Root access (you will use `sudo` for TAP and NAT)

**Note:** Docker is demonstrated via Docker Desktop on Windows, while Firecracker
runs inside an Ubuntu WSL2 environment. This setup mirrors how many developers
experiment with containers and microVMs locally.


## Quick start

### 1) Docker demo
See `docker/README.md`.

### 2) Firecracker demo (WSL2 Ubuntu)
From `firecracker/`:

1. Create VM config + TAP device:
   - `sudo ./setup.sh`

2. Enable NAT (optional, required for internet access from the microVM):
   - `sudo ./nat-toggle.sh enable fc-88-tap0`

3. Start Firecracker:
   - `sudo ./start.sh`

4. From inside the microVM, test connectivity:
   - `ping -c 1 8.8.8.8`

5. Cleanup:
   - `sudo ./teardown.sh`

## When to choose what

- **Docker** is great for packaging and shipping trusted workloads quickly.
- **Firecracker** is a better fit when you need stronger isolation for untrusted or multi-tenant workloads (serverless, sandboxing, CI runners, user-submitted code).

This is not “Docker bad”. It is about understanding boundaries.

## Credits / Further reading

Julia Evans’ Firecracker walkthrough was extremely helpful while setting this up:
https://jvns.ca/blog/2021/01/23/firecracker--start-a-vm-in-less-than-a-second/

