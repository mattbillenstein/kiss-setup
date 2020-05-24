Scripts for installing KISS Linux to a disk image

Run stage1.sh, this will create a disk image with a single partition, mount it
on loopback, install KISS, and then enter the chroot.  Inside the chroot, run
stage2.sh to complete setup and then exit.

When it's complete you can dd this image to an actual disk and resize the
partition, or run the disk image in something like VirtualBox by converting it
to a vdi.
