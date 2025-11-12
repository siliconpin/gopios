#!/bin/bash

set -e

ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "HOSTNAME_PLACEHOLDER" > /etc/hostname
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   HOSTNAME_PLACEHOLDER.localdomain HOSTNAME_PLACEHOLDER
EOF

if [ "BOOT_MODE_PLACEHOLDER" = "UEFI" ]; then
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=gopios --recheck --removable
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=gopios --recheck
else
    grub-install --target=i386-pc --recheck --force DRIVE_PLACEHOLDER
fi


GRUB_FILE="/etc/default/grub"

if grep -q '^GRUB_THEME=' "$GRUB_FILE"; then
    sed -i 's|^GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/gopios/theme.txt"|' "$GRUB_FILE"
else
    echo 'GRUB_THEME="/boot/grub/themes/gopios/theme.txt"' >> "$GRUB_FILE"
fi

if grep -q '^GRUB_TIMEOUT=' "$GRUB_FILE"; then
    sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' "$GRUB_FILE"
else
    echo 'GRUB_TIMEOUT=0' >> "$GRUB_FILE"
fi


sed -i 's/^OS=Linux$/OS=GopiOS/' /etc/grub.d/10_linux

grub-mkconfig -o /boot/grub/grub.cfg 2>/dev/null

if [ "BOOT_MODE_PLACEHOLDER" = "BIOS" ]; then
    parted DRIVE_PLACEHOLDER set 1 boot on
fi

systemctl enable NetworkManager 2>/dev/null
systemctl enable sddm 2>/dev/null
systemctl enable docker 2>/dev/null
systemctl enable systemd-timesyncd 2>/dev/null
systemctl set-default graphical.target 2>/dev/null
systemctl enable bluetooth.service
systemctl enable smb nmb
systemctl --user enable gpg-agent.socket
echo v4l2loopback | tee /etc/modules-load.d/v4l2loopback.conf

echo "root:PASSWORD_PLACEHOLDER" | chpasswd 2>/dev/null
groupadd sambashare
useradd -m -G wheel,docker,sambashare USERNAME_PLACEHOLDER 2>/dev/null

echo "USERNAME_PLACEHOLDER:PASSWORD_PLACEHOLDER" | chpasswd 2>/dev/null
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers 2>/dev/null
# plasma-apply-lookandfeel --apply org.kde.breezedark
pacman-key --init 
pacman-key --populate archlinux 

#chmod +x /opt/rbt/rbt


chmod +x /opt/generate-gpg-key.sh 2>/dev/null
chmod +x /opt/dag.sh 2>/dev/null
chmod +x /opt/set-dark-mode.sh 2>/dev/null
chmod +x /opt/setup-flathub-remote.sh 2>/dev/null
chmod +x /home/USERNAME_PLACEHOLDER/Desktop/Apps/Google-Chrome.AppImage


# Hide faltu desktop menu entry
echo "NoDisplay=true" | sudo tee -a /usr/share/applications/assistant.desktop 2>/dev/null
echo "NoDisplay=true" | sudo tee -a /usr/share/applications/qv4l2.desktop 2>/dev/null
echo "NoDisplay=true" | sudo tee -a /usr/share/applications/qvidcap.desktop 2>/dev/null
# rm /usr/share/applications/vbnc.desktop
echo "NoDisplay=true" | sudo tee -a /usr/share/applications/bssh.desktop 2>/dev/null
echo "NoDisplay=true" | sudo tee -a /usr/share/applications/avahi-discover.desktop 2>/dev/null
echo "NoDisplay=true" | sudo tee -a /usr/share/applications/linguist.desktop 2>/dev/null
echo "NoDisplay=true" | sudo tee -a /usr/share/applications/designer.desktop 2>/dev/null
# rm /usr/share/applications/assistant6.desktop



# Rebuild initramfs
mkinitcpio -P 

# modprobe v4l2loopback
echo "Setup complete!"