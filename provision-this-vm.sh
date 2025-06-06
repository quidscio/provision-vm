#!/usr/bin/env bash
set -euxo pipefail

# ensure we can find all the admin tools even if PATH was minimal
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}"

# must run as root
if (( EUID != 0 )); then
  echo "Run this as root (sudo)" >&2
  exit 1
fi

# verify the Guest Additions ISO is inserted and not already mounted
if ! blkid -o value -s TYPE /dev/cdrom | grep -q '^iso9660$'; then
  echo "Error: no ISO9660 volume detected on /dev/cdrom. Attach the Guest Additions ISO and try again." >&2
  exit 1
fi

if mountpoint -q /mnt/vbga; then
  echo "Error: /mnt/vbga already in use. Unmount it before running this script." >&2
  exit 1
fi

# 0) Create "demo" user if it does not exist
if ! id demo &>/dev/null; then
  useradd -m -s /bin/bash demo
  echo "User 'demo' created."

  # Prompt for the demo user’s password (with confirmation)
  read -rsp "Enter password for 'demo' user: " DEMO_PW
  echo
  read -rsp "Confirm password: " DEMO_PW_CONFIRM
  echo
  if [[ "$DEMO_PW" != "$DEMO_PW_CONFIRM" ]]; then
    echo "Passwords do not match. Exiting." >&2
    exit 1
  fi

  # Set the demo user’s password
  echo "demo:$DEMO_PW" | chpasswd
  echo "Password for 'demo' set."
fi

# import environment changes 
source .env 

# 1) Give demo passwordless sudo
usermod -aG sudo demo
usermod -aG sudo $USER1        # Add any custom users in this way
cat >/etc/sudoers.d/demo <<'EOF'
demo ALL=(ALL) NOPASSWD: ALL
EOF
chmod 0440 /etc/sudoers.d/demo

# 2) Install and enable time sync
apt update
apt install -y systemd-timesyncd
systemctl enable --now systemd-timesyncd
timedatectl status

# 3) Install Guest Additions prerequisites
apt install -y build-essential dkms linux-headers-$(uname -r)

# 4) Mount and run the VirtualBox Guest Additions installer
mkdir -p /mnt/vbga
mount -o loop /dev/cdrom /mnt/vbga
sh /mnt/vbga/VBoxLinuxAdditions.run || true
umount /mnt/vbga
rmdir /mnt/vbga

# 5) Clean up
apt autoremove -y
apt clean

# Ah...none of the following will work as root. Must be done as user where change is desired. 
# 6) Disable screen saver and avoid blanking bug 
# gnome version 
# gsettings set org.gnome.desktop.screensaver lock-enabled false 
# turn off automatic locking after idle
# kwriteconfig5 --file ~/.config/kscreenlockerrc --group Daemon --key Autolock false  
# turn off locking when coming back from suspend/resume
# kwriteconfig5 --file ~/.config/kscreenlockerrc --group Daemon --key LockOnResume false  
# settings will be active on next login/restart  

# 7) Select vs Execute folders and files 
# kwriteconfig5 --file ~/.config/kdeglobals --group KDE --key SingleClick false
# restart 
# kquitapp5 plasmashell && kstart5 plasmashell


echo "Provisioning complete. You can now shut down and snapshot the VM."
