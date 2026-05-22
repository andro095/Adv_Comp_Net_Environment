# Mininet Docker Environment

A fully containerized Mininet environment with Open vSwitch and Python data science tools. This build is specifically designed to run Mininet seamlessly, circumventing common Docker/WSL2 configuration hurdles.

## 📁 Repository Files

* **`Dockerfile`**: The blueprint for the Mininet image. It uses `ubuntu:22.04` as a base and installs Mininet, Open vSwitch, networking tools (`tshark`, `iperf3`, `tcpdump`, `ping`), and a suite of Python data science libraries.
* **`entrypoint.sh`**: The container's startup script. It safely initializes the Open vSwitch database, spins up the OVS daemons, creates a dedicated workspace for your lab, and unlocks volume permissions automatically.
* **`docker-run.sh` & `docker-run.ps1`**: Cross-platform automation CLI scripts to build images, manage containers, and streamline your workflow. 
* **`docker-run.cmd`**: A native Windows batch wrapper that seamlessly forwards commands to the PowerShell script, automatically bypassing local execution policies so you don't have to change your security settings.

---

## 🚀 How to Use

You can manage your Mininet environment using the `docker-run` scripts. A central `lab-output` folder will be created on your host machine to safely store and persist all your work across multiple labs.

* **Unix/Mac/Git Bash:** Use `bash docker-run.sh <command>`
* **Windows (CMD/PowerShell):** Use `docker-run <command>` *(Note: In PowerShell, you may need to type `.\docker-run`)*

### Image Management

```bash
# Build the default image (mymininet:latest)
bash docker-run.sh build

# Build a custom named image
bash docker-run.sh build -i mycustomimage:v1

# Remove an image
bash docker-run.sh clean
bash docker-run.sh clean -i mycustomimage:v1
```
*(Windows users: replace `bash docker-run.sh` with `docker-run`)*

### Container Management

When running a lab, the script will automatically create `/home/student/<lab-name>-output` inside the container, backed by the shared `lab-output` folder on your host.

```bash
# Start a new lab container
bash docker-run.sh run lab-1

# Open a secondary shell in an already running container
bash docker-run.sh shell lab-1

# Check if a container is running
bash docker-run.sh status lab-1

# View the container's background logs
bash docker-run.sh logs lab-1

# Stop a running container
bash docker-run.sh stop lab-1
```
*(Windows users: replace `bash docker-run.sh` with `docker-run`)*

### Options

* `-i`, `--image`: Override the default image name and tag (`mymininet:latest`). Available for the `build`, `run`, and `clean` commands. Format must be `<image-name>:<image-tag>`.

### Test Your Instance

Once inside your primary container shell, use the following command to test your instance and verify that the virtual network hosts can communicate:

```bash
mn --test pingall
```

*(Note: If the command freezes or drops packets due to host-specific WSL2 kernel limitations, bypass the kernel by running `mn --switch ovs,datapath=user --test pingall` instead).*

---

## 🪟 Notes for Windows Users

* **The `.cmd` Wrapper:** We have included a `docker-run.cmd` file in this repository. You do **not** need to change your PowerShell Execution Policy. Simply open Command Prompt, Windows Terminal, or PowerShell and type `docker-run <command>`. The wrapper automatically handles the security bypass for you!
* **Git Bash:** If you prefer a Unix-like experience, you can right-click inside your project folder, select **"Open Git Bash here"**, and use `bash docker-run.sh`. 
* **Line Endings:** Windows saves files with hidden `\r\n` characters. This project's `Dockerfile` automatically uses `dos2unix` to fix `entrypoint.sh` during the build process, so you can freely edit the scripts in Windows text editors like VS Code without breaking the container.

## 🐧 Notes for Unix / Linux / macOS Users

* **No `chmod` required for the helper script:** You can bypass needing to run `chmod +x docker-run.sh` by simply calling it via bash directly (e.g., `bash docker-run.sh run lab1`).
* **Volume Mounts:** The `docker-run.sh` script automatically uses standard `$(pwd)` to map your current directory seamlessly into the container, ensuring your lab files are saved with correct standard Linux pathing.