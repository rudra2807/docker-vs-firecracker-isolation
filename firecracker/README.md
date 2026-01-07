# Firecracker: MicroVM Isolation Model

This section demonstrates **Firecracker microVM isolation** using a real,
bootable microVM with networking enabled.

Unlike containers, Firecracker boots a **separate Linux kernel** inside a
hardware-virtualized boundary (KVM). This provides VM-level isolation while
keeping startup times much lower than traditional virtual machines.

No exploits. No benchmarking tricks. Just a minimal, reproducible setup.

---

## What this demo shows

- A microVM boots with its **own kernel and root filesystem**
- Kernel state is **not shared** with the host
- Networking works via a TAP device and optional NAT
- Guest root has **no authority** over the host system

---

## Environment

This demo is designed to run in:

- **Ubuntu on WSL2**
- Firecracker installed and working
- Root access available via `sudo`

The microVM uses a **minimal Linux distribution (Alpine-based root filesystem)**,
chosen to keep the VM small and fast to boot.

---

## Installing Firecracker

This demo assumes Firecracker is available on the system.

You can either download Firecracker from the official repository or use the
pre-downloaded binary included in this repo.

### Option 1: Use the bundled Firecracker binary

From the root directory:

```bash
tar -xvzf firecracker-v1.14.0-x86_64.tgz
cd release-v1.14.0-x86_64/
sudo mv firecracker-v1.14.0-x86_64 /usr/local/bin/firecracker
```

Verify the installation:

```bash
firecracker --version
```

---
### Option 2: Download from the official repository

You can also download Firecracker directly from the official GitHub releases: 

https://github.com/firecracker-microvm/firecracker/releases

Follow the instructions for your platform, then verify:
```bash
firecracker --version
```

---

## Files in this directory

- `setup.sh`  
  Downloads a kernel and root filesystem, creates a TAP interface, and generates
  a Firecracker VM configuration.

- `start.sh`  
  Boots the Firecracker microVM using the generated configuration.

- `nat-toggle.sh`  
  Enables or disables NAT so the microVM can access the internet.

- `teardown.sh`  
  Cleans up NAT rules and removes the TAP interface.

---

## How to run

All commands below are run from the `firecracker/` directory.

### 1. Set up kernel, rootfs, and networking

```bash
sudo ./setup.sh
```
#### This will:
- Download a minimal Linux kernel and root filesystem
- Create a TAP device for the microVM
- Generate `vmconfig.json` for Firecracker

---

### 2. Enable NAT (optional, required for outbound connectivity)

```bash
sudo ./nat-toggle.sh enable fc-88-tap0
```
This step allows the microVM to reach the internet at the IP level.

---

### 3. Start the microVM

```bash
sudo ./start.sh
```

You will see the Linux boot output in your terminal.

When the microVM finishes booting, it will prompt for login credentials.

#### Default login:
- Username: `root`
- Password: `root`

---

### Verifying isolation inside the microVM
After logging in:
```bash
uname -a
cat /proc/modules | head
```
Expected observations:
- The kernel version differs from the host
- Kernel modules reflect **guest-only** state

---

### Networking behavior (important)

### IP connectivity
If NAT is enabled, this **will work**:
```bash
ping -c 1 1.1.1.1
ping -c 1 8.8.8.8
```

This confirms that the microVM has outbound IP connectivity.

### DNS resolution
This will **NOT work by default:**
```bash
ping google.com
```
DNS is not configured in this minimal setup.

To enable DNS resolution, configure `/etc/resolv.conf` inside the microVM:
```bash
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf
```
After this, DNS resolution will work (for example, `ping google.com`).
Or what you can do is use an Alpine-based setup script such as `setup-alpine`).

DNS configuration is intentionally omitted here to keep the demo focused on **isolation**, not full OS provisioning.

---

### 4. Cleanup
After shutting down the microVM, clean up networking:
```bash
sudo ./teardown.sh
```
This removes NAT rules and deletes the TAP interface.

---
## Why this matters
Firecracker’s design provides a **hard isolation boundary** by default.
There is no privileged mode that removes this boundary, and guest processes cannot directly interact with the host kernel.

This model is particularly useful for:
- Serverless platforms
- Multi-tenant systems
- CI runners
- Sandboxing untrusted code

This is why Firecracker is used under the hood by **AWS Lambda** and **AWS Fargate**.

---
### Notes:
- This demo focuses on isolation, not full OS configuration.
- Startup time and networking behavior may vary depending on your system.
- Firecracker is not a replacement for Docker; it solves a different problem.

---
### Credits / Further reading
Julia Evans’ Firecracker walkthrough was extremely helpful for understanding and
setting up this environment:

https://jvns.ca/blog/2021/01/23/firecracker--start-a-vm-in-less-than-a-second/
