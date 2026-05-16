# Mininet Docker Environment

A fully containerized Mininet environment with Open vSwitch and Python data science tools. This build is specifically designed to run Mininet seamlessly, circumventing common Docker/WSL2 configuration hurdles.

## 📁 Repository Files

* **`Dockerfile`**: The blueprint for the Mininet image. It uses `ubuntu:22.04` as a base and installs Mininet, Open vSwitch, networking tools (`tshark`, `iperf3`, `tcpdump`, `ping`), and a suite of Python data science libraries (`pandas`, `scikit-learn`, `tensorflow`, etc.). It also uses `dos2unix` to ensure cross-platform script compatibility.
* **`entrypoint.sh`**: The container's startup script. It safely initializes the Open vSwitch database, spins up the OVS daemons (`ovsdb-server` and `ovs-vswitchd`) in the background, outputs their status, and drops you into a ready-to-use bash shell.
* **`run.sh`**: A Bash helper script to automate building the image and deploying containers. It automatically detects your operating system and mounts a local volume for your lab outputs.
* **`run.ps1`**: The native Windows PowerShell equivalent of `run.sh`. It performs the exact same automation (building and running) but uses native Windows pathing.

---

## 🚀 How to Use

You can manage your Mininet environment using the provided scripts. 

### 1. Build the Image
Before running any labs, you must build the Docker image. 
* **Unix/Mac/Git Bash:** `bash run.sh build`
* **Windows PowerShell:** `.\run.ps1 build`

### 2. Run a Lab
When you run a lab, the script will automatically create a local folder named `<lab-name>-output` on your host machine and mount it inside the container at `/home/student/<lab-name>-output`.
* **Unix/Mac/Git Bash:** `bash run.sh run my-first-lab`
* **Windows PowerShell:** `.\run.ps1 run my-first-lab`

### 3. Test Your Instance
Once inside the container shell, use the following command to test your instance and verify that the virtual network hosts can communicate:
    mn --test pingall

*(Note: If the command freezes or drops packets due to host-specific WSL2 kernel limitations, you can bypass the kernel entirely by running `mn --switch ovs,datapath=user --test pingall` instead).*

### Help Menu
To see all available commands:
* **Unix/Mac/Git Bash:** `bash run.sh help`
* **Windows PowerShell:** `.\run.ps1 help`

---

## 🪟 Notes for Windows Users

* **PowerShell Execution Policy:** By default, Windows blocks custom `.ps1` scripts. If `.\run.ps1` fails with a security error, open PowerShell as an Administrator and run:
  `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
  You only need to do this once.
* **Git Bash:** If you prefer not to use PowerShell, you can right-click inside your project folder, select **"Open Git Bash here"**, and use `bash run.sh <command>`. The Bash script automatically handles Windows directory paths (`$PWD`).
* **Line Endings (CRLF vs LF):** Windows saves files with hidden `\r\n` characters, which crashes Linux bash scripts. This project's `Dockerfile` automatically uses `dos2unix` to fix `entrypoint.sh` during the build process, so you can freely edit the scripts in Windows text editors like VS Code or Notepad without breaking the container.

## 🐧 Notes for Unix / Linux / macOS Users

* **No `chmod` required for the helper script:** You can bypass needing to run `chmod +x run.sh` by simply calling it via bash directly (e.g., `bash run.sh run lab1`).
* **Volume Mounts:** The `run.sh` script automatically uses standard `$(pwd)` to map your current directory seamlessly into the container, ensuring your lab files are saved with correct standard Linux pathing.