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

## Run on MacBook Air M1 (Vagrant + QEMU)

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
vagrant suspend     # save state quickly
vagrant resume      # resume from suspend
vagrant reload      # restart VM and re-apply networking
vagrant destroy -f  # delete VM (recreates cleanly next time)
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
