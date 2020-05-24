#!/bin/bash -xv

LOOP="/dev/loop7"
ROOT="/dev/loop7p1"

set -eo pipefail

sudo umount root || true
sudo losetup -d $LOOP || true

sudo rm -fR root
mkdir root

rm -f kiss.img

dd if=/dev/zero of=kiss.img bs=1G count=8

fdisk kiss.img <<EOF
o
n
p
1


a
w
EOF

sudo losetup -v -P $LOOP kiss.img
sudo mkfs.ext4 $ROOT
sudo mount $ROOT root

if [ ! -e kiss-chroot.tar.xz ]; then
    wget https://github.com/kisslinux/repo/releases/download/1.10.0/kiss-chroot.tar.xz
    wget https://raw.githubusercontent.com/kisslinux/kiss/master/contrib/kiss-chroot
    chmod 755 kiss-chroot
fi

if [ "$(sha256sum kiss-chroot.tar.xz | awk '{print $1}')" != "daf6858be86a4df76214cbbb41c0d8cd0992799deff667e7fd0b937c6bacc933" ]; then
    echo "Bad sum"
    exit 1
fi

if [ "$(sha256sum kiss-chroot | awk '{print $1}')" != "774c6f31cc938acae1df87cc81221b14137828f0c9e24d7120fd44b961070c91" ]; then
    echo "Bad sum"
    exit 1
fi

sudo tar xvf kiss-chroot.tar.xz -C root --strip-components 1

sudo cp stage2.sh root/

echo "Run ./stage2.sh in the chroot..."

sudo ./kiss-chroot ./root

sudo umount root
sudo losetup -d $LOOP

echo "Success!"
