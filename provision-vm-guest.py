#!/usr/bin/env python3
import os
import re
import subprocess
import sys

def _quote(arg: str) -> str:
    """Wrap in quotes if it contains spaces."""
    return f'"{arg}"' if ' ' in arg else arg

def get_vms():
    """Return a list of VM names registered with VirtualBox."""
    # Prepend the default VirtualBox folder to PATH
    vb_path = r"C:\Program Files\Oracle\VirtualBox"
    os.environ["PATH"] = f"{vb_path};{os.environ.get('PATH', '')}"

    try:
        output = subprocess.check_output(
            ["VBoxManage", "list", "vms"],
            stderr=subprocess.DEVNULL,
            text=True
        )
    except subprocess.CalledProcessError:
        print("Error: Could not run 'VBoxManage list vms'. Make sure VirtualBox is installed.")
        sys.exit(1)

    # Parse lines like:  "YourVMName" {uuid}
    vms = []
    for line in output.splitlines():
        m = re.match(r'^"([^"]+)"', line)
        if m:
            vms.append(m.group(1))
    return vms

def choose_vm(vms):
    """Prompt the user to select a VM by number."""
    print("Available VirtualBox VMs:")
    for idx, vm in enumerate(vms, 1):
        print(f"  {idx}) {vm}")

    while True:
        choice = input("Select a VM by number: ").strip()
        if not choice.isdigit():
            print("Invalid input. Please enter a number.")
            continue
        num = int(choice)
        if 1 <= num <= len(vms):
            return vms[num - 1]
        print(f"Number out of range. Enter between 1 and {len(vms)}.")

def main():
    vms = get_vms()
    if not vms:
        print("No VirtualBox VMs found.")
        sys.exit(0)

    vm_name = choose_vm(vms)
    print(f"\nConfiguring: {vm_name}\n")

    # Enable bidirectional clipboard
    cmd_clip = ["VBoxManage", "modifyvm", vm_name, "--clipboard", "bidirectional"]
    print(".. Command:", ' '.join(_quote(a) for a in cmd_clip))
    subprocess.run(cmd_clip, check=True)

    # Take a "clean-install" snapshot
    cmd_snap = [
        "VBoxManage",
        "snapshot",
        vm_name,
        "take",
        "fully-provisioned",
        "--description",
        "After initial provisioning"
    ]
    print(".. Command:", ' '.join(_quote(a) for a in cmd_snap))
    subprocess.run(cmd_snap, check=True)

    print(f"\n✅ Clipboard enabled and snapshot 'fully-provisioned' taken for VM '{vm_name}'")

if __name__ == "__main__":
    main()
