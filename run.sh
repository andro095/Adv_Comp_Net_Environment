#!/bin/bash

# Function to display help instructions
show_help() {
    echo "=== Mininet Lab Manager Help ==="
    echo "This script automates building and running your Mininet Docker containers."
    echo ""
    echo "Usage:"
    echo "  bash run.sh <command> [arguments]"
    echo ""
    echo "Commands:"
    echo "  build            Builds the Docker image ('mymininet:latest') from the local Dockerfile."
    echo "  run <lab-name>   Starts a container for the specified lab. Automatically mounts a"
    echo "                   local output folder named '<lab-name>-output' to save your work."
    echo "  help, -h, --help Shows this help menu."
    echo ""
    echo "Examples:"
    echo "  bash run.sh build"
    echo "  bash run.sh run lab-1"
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
            echo "[*] Detected Windows environment. Using \${PWD} for volume mount."
            docker run -it --rm --privileged --name "$lab_name" -v "${PWD}/$lab_name-output:/home/student/$lab_name-output" mymininet:latest
            ;;
        *)
            # Native Linux, macOS, or WSL2
            echo "[*] Detected Unix/Linux/WSL environment. Using \$(pwd) for volume mount."
            docker run -it --rm --privileged --name "$lab_name" -v "$(pwd)/$lab_name-output:/home/student/$lab_name-output" mymininet:latest
            ;;
    esac
}

# Main command routing
case "$1" in
    build)
        build_image
        ;;
    run)
        run_lab "$2"
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