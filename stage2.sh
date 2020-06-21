#!/bin/sh

LOOP="/dev/loop7"

set -eo pipefail

#+---------------------------------------------------------------+
#|                                                               |
#|                  ENABLE REPOSITORY SIGNING                    |
#|                                                               |
#| * This step is _entirely optional_ and can also be done       |
#|   after the installation.                                     |
#|                                                               |
#| * Repository signing ensures that all updates have been       |
#|   signed by (Dylan Araps) and further prevents any unsigned   |
#|   updates from reaching your system.                          |
#|                                                               |
#|                                                               |
#|   BUILD AND INSTALL GNUPG1                                    |
#|                                                               |
#|   Welcome to the KISS package manager! These two commands     |
#|   are how individual packages are built and installed on      |
#|   a KISS system.                                              |
#|                                                               |
#$   kiss build   gnupg1                                         |
#$   kiss install gnupg1                                         |
#|                                                               |
#|                                                               |
#|   IMPORT MY (DYLAN ARAPS) KEY                                 |
#|                                                               |
#|   If the GNU keyserver fails on your network, you can try     |
#|   an alternative mirror (pgp.mit.edu for example).            |
#|                                                               |
#|   # Import my public key.                                     |
#$   gpg --keyserver keys.gnupg.net --recv-key 46D62DD9F1DE636E  |
#|                                                               |
#|   # Trust my public key.                                      |
#$   echo trusted-key 0x46d62dd9f1de636e >>/root/.gnupg/gpg.conf |
#|                                                               |
#|                                                               |
#|   ENABLE SIGNATURE VERIFICATION                               |
#|                                                               |
#|   Repository signature verification uses a feature built      |
#|   into git itself (`merge.verifySignatures`)!                 |
#|                                                               |
#|   This can be disabled at any time using the inverse of       |
#|   the git command below.                                      |
#|                                                               |
#|   The same steps can also be followed with 3rd-party          |
#|   repositories if the owner signs their commits.              |
#|                                                               |
#$   cd /var/db/kiss/repo                                        |
#$   git config merge.verifySignatures true                      |
#|                                                               |
#|                                                               |
#+---------------------------------------------------------------+
#
#+---------------------------------------------------------------+
#|                                                               |
#|                        REBUILD KISS                           |
#|                                                               |
#| * This step is entirely optional and you can just use the     |
#|   supplied binaries from the downloaded chroot. This step     |
#|   can also be done after the installation.                    |
#|                                                               |
#|                                                               |
#|   MODIFY COMPILER OPTIONS (optional)                          |
#|                                                               |
#|   These options have been tested and work with every package  |
#|   in the repositories. If you'd like to play it safe, use     |
#|   -O2 or -Os instead of -O3.                                  |
#|                                                               |
#|   If your system has a low amount of memory, omit -pipe.      |
#|   This option speeds up compilation but may use more memory.  |
#|                                                               |
#|   If you intend to transfer packages between machines, omit   |
#|   -march=native. This option tells the compiler to use        |
#|   optimizations unique to your processor's architecture.      |
#|                                                               |
#|   The `-jX` option should match the number of CPU cores       |
#|   available. You can optionally omit this, however builds     |
#|   will then be limited to a single core.                      |
#|                                                               |
#|   # NOTE: The 'O' in '-O3' is the letter O and NOT 0 (ZERO).  |
#$   export CFLAGS="-O3 -pipe -march=native"                     |
#$   export CXXFLAGS="-O3 -pipe -march=native"                   |
#|                                                               |
#|   # NOTE: 4 should be changed to match the number of cores.   |
#$   export MAKEFLAGS="-j4"                                      |
#|                                                               |
#|                                                               |
#|   UPDATE ALL BASE PACKAGES TO THE LATEST VERSION              |
#|                                                               |
#|   This is how updates are performed on a KISS system. This    |
#|   command uses git to pull down changes from all enabled      |
#|   repositories and will then optionally handle the            |
#|   build/install process.                                      |
#|                                                               |
#$   kiss update                                                 |

# update kiss itself, then installed pkgs
echo | kiss update
echo | kiss update

#|                                                               |
#|   REBUILD ALL PACKAGES                                        |
#|                                                               |
#|   Running `kiss build` without specifying packages will       |
#|   start a rebuild of all installed packages on the system.    |
#|                                                               |
#|   Note: The package manager will prompt for user input on     |
#|         completion before installing the build packages.      |
#|                                                               |
#$   cd /var/db/kiss/installed && kiss build *                   |

echo | kiss build $(ls /var/db/kiss/installed)

#|                                                               |
#|                                                               |
#+---------------------------------------------------------------+
#
#+---------------------------------------------------------------+
#|                                                               |
#|                      USERSPACE TOOLS                          |
#|                                                               |
#| * Each kiss action (build, install, etc) has a shorthand      |
#|   alias. From now on, 'kiss b' and 'kiss i' will be used      |
#|   in place of 'kiss build' and 'kiss install'.                |
#|                                                               |
#| * The software below is required unless otherwise stated.     |
#|                                                               |
#|                                                               |
#|   FILESYSTEMS                                                 |
#|                                                               |
#|   # Ext2, Ext3 and Ext4.                                      |
#$   kiss b e2fsprogs                                            |
#$   kiss i e2fsprogs                                            |
#|                                                               |
#|   # fat, vfat and friends (Only needed for UEFI).             |
#$   kiss b dosfstools                                           |
#$   kiss i dosfstools                                           |
#|                                                               |
#|   # Open an issue for additional filesystem support.          |
#|   # Additional filesystems will go here.                      |
#|                                                               |
#|                                                               |
#|   DEVICE MANAGEMENT                                           |
#|                                                               |
#|   # Needed blkid support in eudev.                            |
#$   kiss b util-linux                                           |
#$   kiss i util-linux                                           |
#|                                                               |
#$   kiss b eudev                                                |
#$   kiss i eudev                                                |
#|                                                               |
#|                                                               |
#|   WIFI (optional)                                             |
#|                                                               |
#$   kiss b wpa_supplicant                                       |
#$   kiss i wpa_supplicant                                       |
#|                                                               |
#|                                                               |
#|   DYNAMIC IP ADDRESSING (optional)                            |
#|                                                               |
#$   kiss b dhcpcd                                               |
#$   kiss i dhcpcd                                               |
#|                                                               |
#|                                                               |
#+---------------------------------------------------------------+

for pkg in e2fsprogs dosfstools util-linux eudev dhcpcd; do
  echo | kiss build $pkg
  kiss install $pkg
done

#+---------------------------------------------------------------+
#|                                                               |
#|                         THE KERNEL                            |
#|                                                               |
#| * This step involves configuring and building your own Linux  |
#|   kernel. If you have not done this before, below are a few   |
#|   guides to get you started.                                  |
#|                                                               |
#|   - KernelNewbies                                             |
#|   - Gentoo Wiki                                               |
#|   - Linuxtopia                                                |
#|                                                               |
#|                                                               |
#| * The Linux kernel is not managed by the package manager.     |
#|   The kernel is managed manually by the user.                 |
#|                                                               |
#| * KISS does not support booting using an initramfs. When      |
#|   configuring your kernel ensure that all required            |
#|   file-system, disk controller and USB drivers are built      |
#|   with [*] (Yes) and not [m] (Module).                        |
#|                                                               |
#| * NOTE: A patch may be required for some kernels when built   |
#|         with GCC 10.1.0. Please read the link below (and the  |
#|         patch itself for more information).                   |
#|                                                               |
#|         https://k1ss.org/news/20200509a                       |
#|                                                               |
#|                                                               |
#|   INSTALL REQUIRED PACKAGES                                   |
#|                                                               |
#|   libelf is required in most if not all cases.                |
#|                                                               |
#$   kiss b libelf                                               |
#$   kiss i libelf                                               |
#|                                                               |
#|   ncurses is needed for 'make menuconfig' and can be          |
#|   skipped if you will not be using it.                        |
#|                                                               |
#$   kiss b ncurses                                              |
#$   kiss i ncurses                                              |
#|                                                               |
#|   Perl is needed by the build_OID_registry script which will  |
#|   be executed during your kernel build 99.9% of the time.     |
#|   What this means is that perl is *required*.                 |
#|                                                               |
#$   kiss b perl                                                 |
#$   kiss i perl                                                 |
#|                                                               |

for pkg in libelf ncurses perl; do
  echo | kiss build $pkg
  kiss install $pkg
done

#|   Perl _can_ be avoided by applying the following patch to    |
#|   the kernel sources. The patch replaces the perl script with |
#|   an implementation in POSIX shell (Thanks @E5ten).           |
#|                                                               |
#|   Apply: https://k1ss.org/dist/kernel-no-perl.patch           |
#|                                                               |
#|                                                               |
#|   DOWNLOAD THE KERNEL SOURCES                                 |
#|                                                               |
#|   Kernel releases:                                            |
#|                                                               |
#|   - https://kernel.org                                        |
#|   - https://www.fsfla.org/                                    |
#|                                                               |
#|   A larger list of kernels can be found on the                |
#|   https://wiki.archlinux.org/index.php/Kernel                 |
#|                                                               |
#$   wget KERNEL_SOURCE_URL                                      |

KERNEL_VERSION="5.6.14"
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${KERNEL_VERSION}.tar.xz

#|                                                               |
#|   # Extract the kernel sources.                               |
#$   tar xvf KERNEL_SOURCE.tar.??                                |
#$   cd linux-*                                                  |

tar xf linux-${KERNEL_VERSION}.tar.xz
cd linux-${KERNEL_VERSION}

#|                                                               |
#|                                                               |
#|   DOWNLOAD FIRMWARE BLOBS (if required)                       |
#|                                                               |
#|   To keep the KISS repositories entirely FOSS, the            |
#|   proprietary kernel firmware is omitted. This also           |
#|   makes sense as the kernel itself is manually managed        |
#|   by the user.                                                |
#|                                                               |
#|   Note: This step is only required if your hardware           |
#|   utilizes these drivers.                                     |
#|                                                               |
#|   Sources: kernel.org                                         |
#|                                                               |
#|   # Download and extract the firmware.                        |
#$   wget FIRMWARE_TARBALL.tar.gz                                |
#$   tar xvf linux-firmware-20191022.tar.gz                      |
#|                                                               |
#|   # Copy the required drivers to '/usr/lib/firmware'.         |
#$   mkdir -p /usr/lib/firmware                                  |
#$   cp -R ./path/to/driver /usr/lib/firmware                    |
#|                                                               |
#|                                                               |
#|   CONFIGURE THE KERNEL                                        |
#|                                                               |
#|   You can determine which drivers you need by searching       |
#|   the web for your hardware and the Linux kernel.             |
#|                                                               |
#|   If you require firmware blobs, the drivers you enable       |
#|   must be enabled as [m] (modules). You can also optionally   |
#|   include the firmware in the kernel itself.                  |
#|                                                               |
#|   # Generate a default config with *most* drivers             |
#|   # compiled as `[*]` (not modules).                          |
#$   make defconfig                                              |

make defconfig

#|                                                               |
#|   # Open an interactive menu to edit the generated            |
#|   # config, enabling anything extra you may need.             |
#$   make menuconfig                                             |
#|                                                               |
#|   # Store the generated config for reuse later.               |
#$   cp .config /path/to/somewhere                               |
#|                                                               |
#|                                                               |
#|   BUILD THE KERNEL                                            |
#|                                                               |
#|   This may take a while to complete. The compilation time     |
#|   depends on your hardware and kernel configuration.          |
#|                                                               |
#|   # '-j $(nproc)' does a parallel build using all cores.      |
#$   make -j "$(nproc)"                                          |

make -j $(nproc)

#|                                                               |
#|                                                               |
#|   INSTALL THE KERNEL                                          |
#|                                                               |
#|   Ignore the LILO error, it's harmless.                       |
#|                                                               |
#|   # Install the built modules.                                |
#|   # This installs directly to /lib (symlink to /usr/lib).     |
#$   make modules_install                                        |

make modules_install

#|                                                               |
#|   # Install the built kernel.                                 |
#|   # This installs directly to /boot.                          |
#$   make install                                                |

make install

#|                                                               |
#|   # Rename the kernel.                                        |
#|   # Substitute VERSION for the kernel version you have built. |
#|   # Example: 'vmlinuz-5.4'                                    |
#$   mv /boot/vmlinuz /boot/vmlinuz-VERSION                      |
#$   mv /boot/System.map /boot/System.map-VERSION                |

mv /boot/vmlinuz /boot/vmlinuz-${KERNEL_VERSION}
mv /boot/System.map /boot/System-map-${KERNEL_VERSION}

cd ..

rm -fR linux-${KERNEL_VERSION}*

#|                                                               |
#|                                                               |
#+---------------------------------------------------------------+
#
#+---------------------------------------------------------------+
#|                                                               |
#|                      THE BOOTLOADER                           |
#|                                                               |
#| * The default bootloader is grub (*though nothing prevents    |
#|   you from using whatever bootloader you desire*).            |
#|                                                               |
#| * This bootloader was chosen as most people are familiar      |
#|   with it, both BIOS and UEFI are supported and vast          |
#|   amounts of documentation for it exists                      |
#|                                                               |
#|                                                               |
#|   RECOMMENDED                                                 |
#|                                                               |
#|   Create an /etc/fstab by UUID and additionally pass the      |
#|   PARTUUID as a kernel parameter.                             |
#|                                                               |
#|                                                               |
#|   BUILD AND INSTALL GRUB                                      |
#|                                                               |
#$   kiss b grub                                                 |
#$   kiss i grub                                                 |

echo | kiss build grub
kiss install grub

#|                                                               |
#|   # Required for UEFI.                                        |
#$   kiss b efibootmgr                                           |
#$   kiss i efibootmgr                                           |
#|                                                               |
#|                                                               |
#|   SETUP GRUB                                                  |
#|                                                               |
#|   # BIOS.                                                     |
#$   grub-install /dev/sdX                                       |
#$   grub-mkconfig -o /boot/grub/grub.cfg                        |

grub-install $LOOP
grub-mkconfig -o /boot/grub/grub.cfg

sed -i -e 's:/dev/loop[^ ]*:/dev/sda1:g' /boot/grub/grub.cfg

#|                                                               |
#|   # UEFI (replace 'esp' with the EFI mount point).            |
#$   grub-install --target=x86_64-efi \                          |
#|                --efi-directory=esp \                          |
#|                --bootloader-id=kiss                           |
#$   grub-mkconfig -o /boot/grub/grub.cfg                        |
#|                                                               |
#|                                                               |
#+---------------------------------------------------------------+
#
#+---------------------------------------------------------------+
#|                                                               |
#|                   INSTALL INIT SCRIPTS                        |
#|                                                               |
#| * The default init is busybox init (*though nothing ties      |
#|   you to it*). The below commands install the bootup and      |
#|   shutdown scripts as well as the default inittab config.     |
#|                                                               |
#| * Source code: https://github.com/kisslinux/kiss-init         |
#|                                                               |
#$   kiss b baseinit                                             |
#$   kiss i baseinit                                             |

echo | kiss build baseinit
kiss install baseinit

#|                                                               |
#|                                                               |
#+---------------------------------------------------------------+
#
#+---------------------------------------------------------------+
#|                                                               |
#|               ADD A NORMAL USER (recommended)                 |
#|                                                               |
#|                                                               |
#$   adduser USERNAME                                            |
#|                                                               |
#|                                                               |
#+---------------------------------------------------------------+
#
#+---------------------------------------------------------------+
#|                                                               |
#|               ENABLE THE COMMUNITY REPOSITORY                 |
#|                                                               |
#| * The KISS community repository is maintained by users of the |
#|   distribution and contains packages which aren't in the main |
#|   repositories. This repository is disabled by default.       |
#|                                                               |
#|   # Clone the repository to a location of your choosing.      |
#$   git clone https://github.com/kisslinux/community.git        |
#|                                                               |
#|   # Add the repository to the system-wide 'KISS_PATH'.        |
#|   # The 'KISS_PATH' variable works exactly like 'PATH'.       |
#|   # Each repository is split by ':' and is checked in         |
#|   # the order they're written.                                |
#|   #                                                           |
#|   # Add the full path to the repository you cloned            |
#|   # above to the existing KISS_PATH.                          |
#|   #                                                           |
#|   # NOTE: The subdirectory must also be added.                |
#$   vi /etc/profile.d/kiss_path.sh                              |
#|                                                               |
#|   # Spawn a new login shell to access this repository         |
#|   # immediately.                                              |
#$   sh -l                                                       |
#|                                                               |
#|                                                               |
#+---------------------------------------------------------------+
#
#+---------------------------------------------------------------+
#|                                                               |
#|                   INSTALL XORG (optional)                     |
#|                                                               |
#| * To install Xorg, the input drivers and a basic default set  |
#|   of fonts, run the following commands                        |
#|                                                               |
#$   kiss b xorg-server xinit xf86-input-libinput                |
#|                                                               |
#|   # Installing a base font is recommended as Xorg             |
#|   # and applications require fonts to function.               |
#$   kiss b liberation-fonts                                     |
#$   kiss i liberation-fonts                                     |
#|                                                               |
#|                                                               |
#+---------------------------------------------------------------+
#
#+---------------------------------------------------------------+
#|                                                               |
#|             ADD YOUR USER TO THE RELEVANT GROUPS              |
#|                                                               |
#| * This groups based permissions model may not be suitable if  |
#|   KISS will be used as a multi-seat system. Further           |
#|   configuration can be done at your own discretion.           |
#|                                                               |
#|   # Replace 'USERNAME' with the name of the                   |
#|   # user created above.                                       |
#$   addgroup USERNAME video                                     |
#$   addgroup USERNAME audio                                     |
#|                                                               |
#|                                                               |
#+---------------------------------------------------------------+
#
#+---------------------------------------------------------------+
#|                                                               |
#|                        FURTHER STEPS                          |
#|                                                               |
#| * You should now be able to reboot into your KISS             |
#|   installation. Typical configuration should follow           |
#|   (hostname, creation of users, service configuration,        |
#|   installing a window manager, terminal etc).                 |
#|                                                               |
#| * If you encountered any issues, don't hesitate to open       |
#|   an issue on one of our GitHub repositories, post on         |
#|   https://reddit.com/r/kisslinux or join the IRC server.      |
#|                                                               |
#|   See: https://k1ss.org/contact                               |
#|                                                               |
#|                                                               |
#+---------------------------------------------------------------+

# cleanup
rm stage2.sh
rm -r /root/.cache

# zero unused disk blocks so we compress well...
dd if=/dev/zero of=foo bs=1M 2>/dev/null || true
rm foo

echo "Stage2 complete, please exit this chroot..."
