#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n'

# Gather VM names into an array
mapfile -t VMS < <(VBoxManage list vms | awk -F'"' '{print $2}')

if [ ${#VMS[@]} -eq 0 ]; then
  echo "No VirtualBox VMs found." >&2
  exit 1
fi

# Show numbered menu
echo "Available VirtualBox VMs:"
for i in "${!VMS[@]}"; do
  printf "  %2d) %s\n" $((i+1)) "${VMS[i]}"
done

# Prompt for selection
read -rp "Select a VM by number: " SELECTION

# Validate
if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] \
    || [ "$SELECTION" -lt 1 ] \
    || [ "$SELECTION" -gt "${#VMS[@]}" ]; then
  echo "Invalid selection." >&2
  exit 1
fi

VM="${VMS[SELECTION-1]}"
echo "→ Configuring: $VM"

# Enable bidirectional clipboard
VBoxManage controlvm "$VM" clipboard bidirectional

# Take a clean-install snapshot
SNAP="clean-install"
VBoxManage snapshot "$VM" take "$SNAP" \
  --description "After initial provisioning"

echo "✅ Clipboard set and snapshot '$SNAP' taken for VM '$VM'."
