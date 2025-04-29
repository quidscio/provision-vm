#!/usr/bin/env bash
set -euxo pipefail

# ensure we can find all the admin tools even if PATH was minimal
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH}"

# must NOT run as root
if (( EUID == 0 )); then
  echo "Run this as a user" >&2
  exit 1
fi

# Disable screen saver and avoid blanking bug 
# gnome version 
# gsettings set org.gnome.desktop.screensaver lock-enabled false 

# KDE version
# turn off automatic locking after idle
kwriteconfig5 --file ~/.config/kscreenlockerrc --group Daemon --key Autolock false  
# turn off locking when coming back from suspend/resume
kwriteconfig5 --file ~/.config/kscreenlockerrc --group Daemon --key LockOnResume false  
# settings will be active on next login/restart  

# 7) Select vs Execute folders and files 
kwriteconfig5 --file ~/.config/kdeglobals --group KDE --key SingleClick false
# restart 
# kquitapp5 plasmashell && kstart5 plasmashell


echo "User config complete for ${USER}" 
echo "You may need to restart your session to enjoy all changes." 