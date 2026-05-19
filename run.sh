#!/bin/bash

# Function to display help instructions
show_help() {
    echo "=== Mininet Lab Manager Help ==="
    echo "This script automates building, running, and connecting to your Mininet Docker containers."
    echo ""
    echo "Usage:"
    echo "  bash run.sh <command> [arguments]"
    echo ""
    echo "Commands:"
    echo "  build            Builds the Docker image ('mymininet:latest') from the local Dockerfile."
    echo "  run <lab-name>   Starts a container for the specified lab. Automatically mounts a"
    echo "                   central 'lab-output' folder to save and share work across labs."
    echo "  exec <lab-name>  Opens a new bash shell inside an ALREADY RUNNING lab container."
    echo "                   Useful for running secondary commands (like tcpdump) in a new tab."
    echo "  help, -h, --help Shows this help menu."
    echo ""
    echo "Examples:"
    echo "  bash run.sh build"
    echo "  bash run.sh run lab-2"
    echo "  bash run.sh exec lab-2"
    echo "================================"
}

# Function to handle building the Docker image
build_image() {
    echo "[*] Building Docker image 'mymininet:latest'..."
    docker build -t mymininet:latest .
}

# Function to handle running the lab
run_lab() {
    local lab_name="$1"

    # Validate that a lab name was provided
    if [ -z "$lab_name" ]; then
        echo "Error: You must provide a lab name."
        echo "Type 'bash run.sh help' for usage instructions."
        exit 1
    fi

    echo "[*] Starting lab: $lab_name"

    # Detect the operating system
    OS=$(uname -s)
    
    case "$OS" in
        CYGWIN*|MINGW*|MSYS*)
            # Windows environments (Git Bash, MSYS2, etc.)
            echo "[*] Detected Windows environment. Using \${PWD}/lab-output for volume mount."
            docker run -it --rm --privileged --name "$lab_name" -e LAB_NAME="$lab_name" -v "${PWD}/lab-output:/home/student" mymininet:latest
            ;;
        *)
            # Native Linux, macOS, or WSL2
            echo "[*] Detected Unix/Linux/WSL environment. Using \$(pwd)/lab-output for volume mount."
            docker run -it --rm --privileged --name "$lab_name" -e LAB_NAME="$lab_name" -v "$(pwd)/lab-output:/home/student" mymininet:latest
            ;;
    esac
}

# Function to connect to a running lab
exec_lab() {
    local lab_name="$1"

    if [ -z "$lab_name" ]; then
        echo "Error: You must provide a lab name to connect to."
        echo "Type 'bash run.sh help' for usage instructions."
        exit 1
    fi

    echo "[*] Connecting to running lab: $lab_name"
    docker exec -it "$lab_name" bash
}

# Main command routing
case "$1" in
    build)
        build_image
        ;;
    run)
        run_lab "$2"
        ;;
    exec)
        exec_lab "$2"
        ;;
    help|-h|--help)
        show_help
        ;;
    *)
        echo "Invalid command or no command provided."
        echo "Type 'bash run.sh help' for usage instructions."
        exit 1
        ;;
esac