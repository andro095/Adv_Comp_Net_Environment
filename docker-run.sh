#!/bin/bash

# Default Variables
DEFAULT_IMAGE_NAME="mymininet"
DEFAULT_IMAGE_TAG="latest"
IMAGE_FULL_NAME="${DEFAULT_IMAGE_NAME}:${DEFAULT_IMAGE_TAG}"

COMMAND=""
TARGET=""

# Argument Parsing
while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--image)
            if [[ -z "$2" || "$2" == -* ]]; then
                echo "Error: --image (-i) parameter specified but no value provided."
                echo "Format required: <image-name>:<image-tag>"
                exit 1
            fi
            IMAGE_FULL_NAME="$2"
            shift 2
            ;;
        help|-h|--help)
            COMMAND="help"
            shift
            ;;
        *)
            if [[ -z "$COMMAND" ]]; then
                COMMAND="$1"
            elif [[ -z "$TARGET" ]]; then
                TARGET="$1"
            fi
            shift
            ;;
    esac
done

# Helper: Check if container exists and is running
check_running() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "Error: You must provide a container name for this command."
        exit 1
    fi

    # Inspect the container. Suppress errors if it doesn't exist.
    local is_running
    is_running=$(docker container inspect -f '{{.State.Running}}' "$name" 2>/dev/null || echo "false")
    
    if [ "$is_running" != "true" ]; then
        echo "Error: Container '$name' does not exist or is not running."
        exit 1
    fi
}

show_help() {
    echo "=== Mininet Lab Manager Help ==="
    echo "Usage: bash docker-run.sh <command> [lab-name] [-i <image-name>:<image-tag>]"
    echo ""
    echo "Commands:"
    echo "  build            Builds the Docker image."
    echo "  run <lab-name>   Starts a container and mounts the 'lab-output' folder."
    echo "  shell <lab-name> Opens a bash shell inside an ALREADY RUNNING lab container."
    echo "  stop <lab-name>  Stops a running lab container."
    echo "  status <lab-name> Checks if a lab container is currently running."
    echo "  logs <lab-name>  Prints the terminal logs of a running container."
    echo "  clean            Removes the specified Docker image."
    echo "  help             Shows this help menu."
    echo ""
    echo "Options:"
    echo "  -i, --image      Specify a custom image name and tag (default: $DEFAULT_IMAGE_NAME:$DEFAULT_IMAGE_TAG)."
    echo ""
    echo "Examples:"
    echo "  bash docker-run.sh build"
    echo "  bash docker-run.sh run lab-2 -i mymininet:v2"
    echo "  bash docker-run.sh shell lab-2"
    echo "  bash docker-run.sh clean --image custom_name:1.0"
    echo "================================"
}

build_image() {
    echo "[*] Building Docker image '$IMAGE_FULL_NAME'..."
    docker build -t "$IMAGE_FULL_NAME" .
}

run_lab() {
    if [ -z "$TARGET" ]; then
        echo "Error: You must provide a lab name."
        exit 1
    fi

    echo "[*] Starting lab: $TARGET using image: $IMAGE_FULL_NAME"
    OS=$(uname -s)
    
    # Define extra volume mounts for the final project workspace
    EXTRA_MOUNTS=""
    if [ "$TARGET" = "final-project" ]; then
        EXTRA_MOUNTS="-v /Users/andro095/Documents/dev/UoG/S26/ACN_Final_Project:/home/student/final-project-output"
        echo "[*] Mount detected: binding /Users/andro095/Documents/dev/UoG/S26/ACN_Final_Project to /home/student/final-project-output"
    fi

    case "$OS" in
        CYGWIN*|MINGW*|MSYS*)
            docker run -it --rm --privileged --name "$TARGET" -e LAB_NAME="$TARGET" -v "${PWD}/lab-output:/home/student" $EXTRA_MOUNTS "$IMAGE_FULL_NAME"
            ;;
        *)
            docker run -it --rm --privileged --name "$TARGET" -e LAB_NAME="$TARGET" -v "$(pwd)/lab-output:/home/student" $EXTRA_MOUNTS "$IMAGE_FULL_NAME"
            ;;
    esac
}

clean_image() {
    if ! docker image inspect "$IMAGE_FULL_NAME" >/dev/null 2>&1; then
        echo "Error: Image '$IMAGE_FULL_NAME' does not exist."
        exit 1
    fi
    echo "[*] Removing image '$IMAGE_FULL_NAME'..."
    docker rmi "$IMAGE_FULL_NAME"
}

# Main routing
case "$COMMAND" in
    build) build_image ;;
    run) run_lab ;;
    clean) clean_image ;;
    shell)
        check_running "$TARGET"
        echo "[*] Connecting to running lab: $TARGET"
        # NEW: Added the -w flag to force the shell into the specific lab output directory
        docker exec -it -w "/home/student/${TARGET}-output" "$TARGET" bash
        ;;
    stop)
        check_running "$TARGET"
        echo "[*] Stopping lab: $TARGET"
        docker stop "$TARGET"
        ;;
    status)
        check_running "$TARGET"
        echo "[*] Status: Container '$TARGET' is currently RUNNING."
        ;;
    logs)
        check_running "$TARGET"
        echo "[*] Fetching logs for: $TARGET"
        docker logs "$TARGET"
        ;;
    help|"") show_help ;;
    *)
        echo "Error: Invalid command '$COMMAND'."
        exit 1
        ;;
esac