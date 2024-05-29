#Creating /etc/fstab File
cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type     options             dump  fsck
#                                                              order

/dev/nvme0n1p1     /boot        vfat    noauto,defaults     1     2
/dev/nvme0n1p5     /            ext4    defaults            1     1

# End /etc/fstab
EOF

#Linux-6.7.4
cd $LFS/sources
tar -xvf linux-6.7.4.tar.xz
cd linux-6.7.4

make mrproper

make defconfig

make menuconfig

make

make modules_install

# umount /mnt/lfs/boot from host system in a separate terminal window
# umount /mnt/lfs/boot

mount /boot

cp -iv arch/x86/boot/bzImage /boot/vmlinuz-6.7.4-lfs-12.1-systemd

cp -iv System.map /boot/System.map-6.7.4

cp -iv .config /boot/config-6.7.4

cp -r Documentation -T /usr/share/doc/linux-6.7.4

chown -R 0:0 ../linux-6.7.4

install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF

