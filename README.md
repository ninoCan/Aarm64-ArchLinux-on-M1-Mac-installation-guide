# Booting ArchLinux with aarch64 on Mac M1

## Download qemu and utm

    $ brew install qemu utm

> UTM is an user-friendly graphical interface to qemu, it is not strictly necessary to use UTM and 
> qemu can be used directly to create the virtual disks. TODO: add instructions for this

## From Alpine to Arch

Unfortunately the ArchArm doesn't provide images for Mac, this is a way around that starts from
an Alpine Linux kernel and mounts Arch instead

Fetch the latest aarch64 image from the official site:
https://dl-cdn.alpinelinux.org/alpine/v3.15/releases/aarch64/alpine-standard-3.15.4-aarch64.iso

Create a new linux virtual machine from the above iso, and start it.
Follow the [alpine-draft.sh](alpine-draft.sh) to substitute the alpine kernel with the ArchLinux arm64

Check the booting method is not pointing to the image in the `CD/DVD` section, in case `Clear`

## Arch installation

The virtual machine has now a minimal Arch boot installatio with a user `root` (password `root`).
**Change this password while finalizing the installation**

> Follow the [Arch installation guide](https://wiki.archlinux.org/title/Installation_guide#installation)
> (you can skip the preinstallation part) to complete the installation as you like
> TODO: write a script to automate this

## Vagrantfile

> TODO: add vagrantfile to automate the whole process with vagrant
