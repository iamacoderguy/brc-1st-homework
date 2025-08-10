# brc-1st-homework

**Requirement: Build a x86_64 Linux System with Auto-starting Hello World**

## Core Requirements

1. **Basic Part:**

   - Use Buildroot to build a x86_64 Linux system (kernel + root filesystem)
   - Successfully boot the system in QEMU and enter the Shell

2. **Advanced Part:**
   - Write a "Hello World" program in C
   - Configure the system to automatically run this program at startup

---

## Option 1 — Run on MacBook Air M1 (Vagrant + QEMU)

This repo includes a `Vagrantfile` prepared for **Apple Silicon**.  
It boots an **ARM64 Ubuntu 24.04** guest via the **qemu** provider, then installs the host tools you need to cross-build **x86_64** with Buildroot and boot it with `qemu-system-x86_64`.

### Prerequisites (host macOS)

```bash
# Install Homebrew if you don’t have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Vagrant, QEMU, and the QEMU provider for Vagrant
brew install vagrant qemu
vagrant plugin install vagrant-qemu
```

> **Note:** Don’t commit the `.vagrant/` folder. Add it to `.gitignore`.

---

### Start the VM

```bash
# From this repo’s root (where Vagrantfile lives):
vagrant up --provider=qemu
vagrant ssh
```

---

### What the VM already has

- Ubuntu 24.04 (ARM64) guest
- Tooling for Buildroot (`gcc`, `make`, `ncurses`, etc.)
- `qemu-system-x86_64` to run your x86_64 image
- Buildroot **2025.05** tarball downloaded & extracted (by provisioning)

---

### Manage the VM

```bash
# leave the SSH session
exit   # or Ctrl+D

vagrant halt || true      # stop VM (recommended when not in use)
vagrant suspend           # save state quickly
vagrant resume            # resume from suspend
vagrant reload            # restart VM and re-apply networking
vagrant destroy -f        # delete VM (recreates cleanly next time)
```

---

### Troubleshooting (Apple Silicon tips)

- **Port 50022 already in use**

  ```bash
  lsof -iTCP:50022 -sTCP:LISTEN -n -P
  kill -9 <PID>        # or: pkill -f qemu-system
  vagrant global-status --prune
  vagrant up --provider=qemu
  ```

- **Build slow**
  Increase resources in `Vagrantfile`:
  ```ruby
  VM_MEMORY = 8192
  VM_CORES  = 4
  ```
  Then:
  ```bash
  vagrant reload --provision
  ```

---

### .gitignore recommendation

```gitignore
.vagrant/
*.log
```

---

## Option 2 — Run on GitHub Codespaces (faster)

If you don't want to run a VM locally, you can use GitHub Codespaces.  
This runs an **Ubuntu 24.04 x86_64** environment directly in the cloud.

### Check OS and install dependencies

```bash
# Check current OS - expected that it should be Ubuntu (22.04/24.04) x86_64.
cat /etc/os-release
uname -a

# Install dependencies - Details at https://buildroot.org/downloads/manual/manual.html#requirement
sudo apt-get update
sudo apt-get install -y \
  build-essential gcc g++ make \
  sed gawk bash patch perl tar gzip bzip2 xz-utils \
  cpio unzip rsync file bc wget python3 \
  libncurses-dev libssl-dev \
  qemu-system-x86 qemu-utils
```

---

### Download and extract Buildroot

```bash
wget https://buildroot.org/downloads/buildroot-2025.05.tar.xz
tar xf buildroot-2025.05.tar.xz
```

---

## Build the x86_64 system inside the VM

```bash
# inside the VM
cd ~/buildroot-2025.05
# or from GitHub Codespaces
cd buildroot-2025.05

make qemu_x86_64_defconfig
make -j"$(nproc)"
```

Artifacts will be under:

```
output/images/
├── bzImage
└── rootfs.ext2
```

To copy to the real machine, we can copy to the shared vagrant folder

```bash
#  ~/buildroot-2025.05
cp output/images/bzImage /vagrant/
cp output/images/rootfs.ext2 /vagrant/
```

---

### Boot with QEMU (serial console, no GUI)

```bash
cd buildroot-2025.05/output/images
chmod +x start-qemu.sh
./start-qemu.sh --serial-only
```

or we can start with a simple version

```bash
qemu-system-x86_64 \
  -kernel output/images/bzImage \
  -append "console=ttyS0 root=/dev/vda rw rootfstype=ext2 rootwait" \
  -drive file=output/images/rootfs.ext2,format=raw,if=virtio \
  -serial mon:stdio -nographic
```

You should see kernel logs and a shell login on the serial console.

---

## (Advanced) Auto-start “Hello World”

Quick path using an overlay:

```bash
# inside the VM, from ~/buildroot-2025.05 / in GitHub Codespaces, from buildroot-2025.05
make menuconfig
# Target packages → enable "hello"
# System configuration → Root filesystem overlay directories → add: board/myoverlay

mkdir -p board/myoverlay/etc/init.d
cat > board/myoverlay/etc/init.d/S99hello << 'EOF'
#!/bin/sh
case "$1" in
  start)
    if command -v hello >/dev/null 2>&1; then
      echo "[init] running hello..."
      hello
    fi
    ;;
esac
exit 0
EOF
chmod +x board/myoverlay/etc/init.d/S99hello

make -j"$(nproc)"
# boot again with the QEMU command above; you’ll see the hello message at boot
```

---
