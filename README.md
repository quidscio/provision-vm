# provision-vm

A toolkit for provisioning standardized Linux virtual machines in VirtualBox, designed to create consistent testing environments. This repository contains scripts to automate the setup of Ubuntu/Debian-based VMs with VirtualBox Guest Additions, user configuration, and desktop environment settings.

## Table of Contents

- [provision-vm](#provision-vm)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Prerequisites](#prerequisites)
    - [Host System Requirements](#host-system-requirements)
    - [VM Requirements](#vm-requirements)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Step 1: Provision the VM (Guest)](#step-1-provision-the-vm-guest)
    - [Step 2: Configure User Settings](#step-2-configure-user-settings)
    - [Step 3: Finalize VM Configuration (Host)](#step-3-finalize-vm-configuration-host)
  - [Scripts Description](#scripts-description)
    - [provision-this-vm.sh](#provision-this-vmsh)
    - [provision-this-user.sh](#provision-this-usersh)
    - [provision-vm-guest.py](#provision-vm-guestpy)
  - [Configuration Details](#configuration-details)
    - [Created User](#created-user)
    - [Custom\_User (optional)](#custom_user-optional)
    - [Desktop Environment Settings (KDE)](#desktop-environment-settings-kde)
    - [VirtualBox Settings](#virtualbox-settings)
  - [Troubleshooting](#troubleshooting)
    - [Guest Additions Installation Fails](#guest-additions-installation-fails)
    - [Scripts Won't Execute](#scripts-wont-execute)
    - [KDE Settings Not Applied](#kde-settings-not-applied)
    - [VBoxManage Not Found (Windows)](#vboxmanage-not-found-windows)
    - [Environment Variables](#environment-variables)

## Overview

This toolkit provides three scripts that work together to create a fully configured Linux VM:

1. **provision-this-vm.sh** - Run inside the VM as root to install Guest Additions and create a demo user
2. **provision-this-user.sh** - Run inside the VM as the user to configure desktop settings
3. **provision-vm-guest.py** - Run on the host to enable clipboard sharing and create a snapshot

## Prerequisites

### Host System Requirements
- VirtualBox installed (tested with VirtualBox 6.x/7.x)
- Python 3.x (for the host configuration script)
- Windows, macOS, or Linux host OS

### VM Requirements
- Debian 12 tested as Guest
- Guest using KDE Plasma desktop environment to support desktop config 
- VirtualBox Guest Additions ISO attached to the VM

## Installation

1. Clone this repository or download the scripts to both your host machine and the VM:
   ```bash
   git clone <repository-url>
   cd provision-vm
   ```

2. Copy `provision-this-vm.sh` and `provision-this-user.sh` to the VM using shared folders or SCP

3. Ensure scripts are executable:
   ```bash
   chmod +x provision-this-vm.sh
   chmod +x provision-this-user.sh
   chmod +x provision-vm-guest.py
   ```

## Usage

### Step 1: Provision the VM (Guest)

1. Start your VM and log in
2. Insert the VirtualBox Guest Additions ISO:
   - In VirtualBox menu: Devices → Insert Guest Additions CD image...
3. Open a terminal and navigate to the script location
4. Create a `.env` file if you need to set a custom user in addition to demo (optional). Entry would be `USER1=custom_user` 
5. Run the provisioning script as root:
   ```bash
   sudo ./provision-this-vm.sh
   ```
   - You'll be prompted to create a password for the 'demo' user if it doesn't exist
   - The script will install necessary packages and Guest Additions

### Step 2: Configure User Settings

1. Log out and log back in as each user whose settings you want to configure (e.g., 'demo' and/or custom_user)
2. Run the user configuration script:
   ```bash
   ./provision-this-user.sh
   ```
   - This disables screen locking and configures KDE to use double-click instead of single-click

### Step 3: Finalize VM Configuration (Host)

1. Shut down the VM
2. On your host machine, run the Python script:
   ```bash
   python provision-vm-guest.py
   ```
   - Select your VM from the list
   - The script will enable bidirectional clipboard and create a snapshot

## Scripts Description

### provision-this-vm.sh
- Creates a 'demo' user with sudo privileges (if not exists)
- Enables passwordless sudo for the demo user and custom_user if enabled 
- Installs and configures time synchronization
- Installs VirtualBox Guest Additions with required dependencies
- Cleans up the system

### provision-this-user.sh
- Disables KDE screen locking and screensaver
- Changes folder behavior from single-click to double-click
- Must be run as the target user (not root)

### provision-vm-guest.py
- Lists all VirtualBox VMs on the host
- Enables bidirectional clipboard sharing
- Creates a "fully-provisioned" snapshot for easy restoration

## Configuration Details

### Created User
- Username: `demo`
- Privileges: Full sudo access without password
- Shell: `/bin/bash`

### Custom_User (optional)
- Privileges: Full sudo access without password

### Desktop Environment Settings (KDE)
Available for `demo` and `custom_user`
- Screen locking: Disabled
- Auto-lock on idle: Disabled
- Lock on resume: Disabled
- Folder interaction: Double-click to open

### VirtualBox Settings
- Guest Additions: Installed
- Clipboard: Bidirectional
- Snapshot: "fully-provisioned" created after setup

## Troubleshooting

### Guest Additions Installation Fails
- Ensure the Guest Additions ISO is properly inserted
- Check that `/dev/cdrom` contains the ISO: `blkid /dev/cdrom`
- Verify kernel headers match running kernel: `uname -r`

### Scripts Won't Execute
- Check file permissions: `ls -la provision-*.sh`
- Ensure line endings are Unix-style (LF, not CRLF)

### KDE Settings Not Applied
- Log out and log back in after running `provision-this-user.sh`
- Verify you're running KDE: `echo $XDG_CURRENT_DESKTOP`

### VBoxManage Not Found (Windows)
- The Python script automatically adds VirtualBox to PATH
- If issues persist, add VirtualBox to your system PATH manually

### Environment Variables
- Custom users can be added by creating a `.env` file with `USER1=custom_user`
- The `.env` file is sourced by `provision-this-vm.sh`