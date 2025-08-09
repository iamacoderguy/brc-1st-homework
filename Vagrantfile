################################################################################
#
# Vagrantfile for Mac M1 + QEMU provider  (clean for Ubuntu 24.04 ARM64)
#
################################################################################

RELEASE = '2025.05'

# Adjust RAM / CPU for guest VM
VM_MEMORY = 4096
VM_CORES  = 2

Vagrant.configure('2') do |config|
  # ARM64 guest box for QEMU
  config.vm.box = 'cloud-image/ubuntu-24.04'

  # Override SSH user
  # config.ssh.username = "ubuntu"
  # config.ssh.insert_key = false

  # Set boot timeout
  config.vm.boot_timeout = 900

  config.vm.provider :qemu do |v, _|
    v.memory      = VM_MEMORY
    v.cpus        = VM_CORES
    v.machine     = 'virt'        # QEMU ARM virtual machine
    v.cpu         = 'cortex-a72'  # Emulate a 64-bit ARM core
    v.accelerator = 'hvf'         # macOS Hypervisor.framework acceleration
  end

  # Provision: install build tools & QEMU x86_64 inside ARM guest
  # (Remove i386 + old VCS bzr/cvs/hg/svn; use libncurses-dev on Ubuntu 24.04)
  config.vm.provision 'shell', privileged: true, inline: <<-SHELL
    apt-get -q update
    apt-get -q -y install \
      build-essential libncurses-dev \
      git rsync unzip bc wget curl file python3 \
      libssl-dev libelf-dev \
      qemu-system-x86 qemu-utils
    apt-get -q -y autoremove
    apt-get -q -y clean
    update-locale LC_ALL=C
  SHELL

  # Provision: download and extract Buildroot release tarball
  config.vm.provision 'shell', privileged: false, inline: <<-SHELL
    set -e
    echo "Downloading and extracting Buildroot #{RELEASE}"
    test -f buildroot-#{RELEASE}.tar.gz || \
      wget -q -c http://buildroot.org/downloads/buildroot-#{RELEASE}.tar.gz
    test -d buildroot-#{RELEASE} || tar axf buildroot-#{RELEASE}.tar.gz
  SHELL
end