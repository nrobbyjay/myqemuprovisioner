# 📦 MyQemuProvisioner

Provision QEMU virtual machines as simply as possible—no coding required.

---

## 🚀 Overview

This tool helps you quickly set up a QEMU virtual machine from an ISO image. It prompts you to select an ISO file and automatically creates a virtual disk. Once provisioning is done, it generates launch scripts for starting your VM with or without a display.

---

## ✅ Prerequisites

1. **QEMU Installed**
   - Ensure QEMU is installed on your system.
2. **QEMU in PATH**
   - Add QEMU to your system environment variables so it’s accessible from PowerShell.
3. **PowerShell Script Execution**
   - Enable unrestricted script execution:
     ```powershell
     Set-ExecutionPolicy Unrestricted -Scope CurrentUser
     ```

---

## 📖 How It Works

1. Run `provision.ps1`.
2. A file picker will appear—select the ISO file you want to use for installation.
3. The script creates a virtual hard disk (`hdd.qcow2`) in the same directory.
4. QEMU launches and begins the OS installation.

✅ After installation and closing QEMU, the script generates:
- **`launch.ps1`** – Launches the VM headless (background mode, no display).
- **`launch_sdl.ps1`** – Launches the VM with a display window (frontend mode).

---

## 📂 Generated Files

- `hdd.qcow2` – Your VM’s virtual hard disk.
- `launch.ps1` – Launches the VM in headless mode.
- `launch_sdl.ps1` – Launches the VM with SDL frontend display.

---

## 📝 Usage Example

Run this in PowerShell:

```powershell

.\provision.ps1

```

## ⚠️ Notes
The ISO and generated files should reside in the same directory as provision.ps1.

SDL mode provides a basic GUI window. Use launch.ps1 for background/headless operation.