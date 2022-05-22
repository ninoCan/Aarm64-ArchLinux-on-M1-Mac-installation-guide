#### Minimal alpine setup
#### ref: https://wiki.alpinelinux.org/wiki/Alpine_setup_scripts#setup-alpine

# Start systemclock
service hwclock start

# Set up interfaces
cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
    hostname alpine-test
EOF

# Prevent overwriting of /etc/resolv.conf
echo 'RESOLV_CONF="no"' >> /etc/udhcpd.conf

# Start networking daemon
/etc/init.d/networking --quiet start &

# Add google DNS to resolve addresses
setup-dns -d google.com -n 8.8.8.8 8.8.4.4

# Add a random repo to the mirros
setup-apkrepos -r

# Setup tools needed to install arch
apk add curl e2fsprogs efibootmgr libarchive-tools parted

#### Partition the virtual device

# Create a GPT partition table
parted /dev/vda -- mklabel gpt
# Create a 256M EFI System Partition
parted /dev/vda -- mkpart '"EFI System Partition"' fat32 1MB 512MB
# Mark the EFI System Partition as esp:
parted /dev/vda -- set 1 esp on
# Create the root partition
parted /dev/vda -- mkpart '"Arch Linux root"' ext4 512MB 100%

# Format the labled partitions
mkfs.vfat -F 32 -n boot /dev/vda1
mkfs.ext4 -L archlinux /dev/vda2

# Mount the ext4 root partition onto /mnt/ by running
mount -t ext4 /dev/vda2 /mnt/
# Create the /mnt/boot/ folder to mount the EFI System Partition and mount it
mkdir -p /mnt/boot/ && mount -t vfat /dev/vda1 /mnt/boot/

#### Download and install Archlinux

# Download the latest Archlinux ARM image and mount it
curl -L http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz | bsdtar -xpC /mnt/

# Modify the fstab file to define ho to mount partitions
echo '/dev/vda1 /boot vfat defaults 0 2' >> /mnt/etc/fstab

# Initialize the EFI Boot Stub
# ref: https://www.kernel.org/doc/html/latest/admin-guide/efi-stub.html
efibootmgr --create \ # create new boot entry
--disk /dev/vda \ # point at the virtual disk
--part 1 \ # specify the boot partition
--label "Arch Linux" \ # set the boot manager display lable
--loader /Image\ # use EFISTUB kernel
--unicode 'console=tty1 quiet root=/dev/vda2 rw initrd=\initramfs-linux.img' #add bootloader arguments

# unmount partitions and shut down
umount /mnt/boot/
umount /mnt/
poweroff
