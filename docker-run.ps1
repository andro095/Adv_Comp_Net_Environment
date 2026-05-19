<#
.SYNOPSIS
    Mininet Lab Manager Help
#>

param (
    [Parameter(Position=0)]
    [string]$Action = "help",

    [Parameter(Position=1)]
    [string]$TargetName = "",

    [Alias("i", "image")]
    [string]$ImageNameTag = ""
)

$DEFAULT_IMAGE_NAME = "mymininet"
$DEFAULT_IMAGE_TAG = "latest"
$IMAGE_FULL_NAME = "$DEFAULT_IMAGE_NAME:$DEFAULT_IMAGE_TAG"

# Handle Image Parameter Logic
if ($PSBoundParameters.ContainsKey('ImageNameTag')) {
    if ([string]::IsNullOrWhiteSpace($ImageNameTag)) {
        Write-Host "Error: --image (-i) parameter specified but no value provided." -ForegroundColor Red
        Write-Host "Format required: <image-name>:<image-tag>"
        exit 1
    }
    $IMAGE_FULL_NAME = $ImageNameTag
}

function Show-Help {
    Write-Host "=== Mininet Lab Manager Help ===" -ForegroundColor Cyan
    Write-Host "Usage: .\docker-run.ps1 <command> [lab-name] [-i <image-name>:<image-tag>]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  build            Builds the Docker image."
    Write-Host "  run <lab-name>   Starts a container and mounts the 'lab-output' folder."
    Write-Host "  shell <lab-name> Opens a bash shell inside an ALREADY RUNNING lab container."
    Write-Host "  stop <lab-name>  Stops a running lab container."
    Write-Host "  status <lab-name> Checks if a lab container is currently running."
    Write-Host "  logs <lab-name>  Prints the terminal logs of a running container."
    Write-Host "  clean            Removes the specified Docker image."
    Write-Host "  help             Shows this help menu."
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -i, --image      Specify a custom image name and tag (default: $DEFAULT_IMAGE_NAME:$DEFAULT_IMAGE_TAG)."
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\docker-run.ps1 build"
    Write-Host "  .\docker-run.ps1 run lab-2 -i mymininet:v2"
    Write-Host "  .\docker-run.ps1 clean -i custom_name:1.0"
    Write-Host "================================" -ForegroundColor Cyan
}

function Check-Running {
    param([string]$Name)
    if ([string]::IsNullOrWhiteSpace($Name)) {
        Write-Host "Error: You must provide a container name for this command." -ForegroundColor Red
        exit 1
    }
    $isRunning = (docker container inspect -f '{{.State.Running}}' $Name 2>$null)
    if ($isRunning -ne 'true') {
        Write-Host "Error: Container '$Name' does not exist or is not running." -ForegroundColor Red
        exit 1
    }
}

switch -Regex ($Action.ToLower()) {
    "^build$" {
        Write-Host "[*] Building Docker image '$IMAGE_FULL_NAME'..." -ForegroundColor Yellow
        docker build -t $IMAGE_FULL_NAME .
    }
    "^run$" {
        if ([string]::IsNullOrWhiteSpace($TargetName)) {
            Write-Host "Error: You must provide a lab name." -ForegroundColor Red
            exit 1
        }
        Write-Host "[*] Starting lab: $TargetName using image: $IMAGE_FULL_NAME" -ForegroundColor Yellow
        $CurrentDir = $PWD.Path
        $VolumeMount = "$CurrentDir\lab-output:/home/student" -replace "\\", "/"
        docker run -it --rm --privileged --name $TargetName -e LAB_NAME=$TargetName -v $VolumeMount $IMAGE_FULL_NAME
    }
    "^shell$" {
        Check-Running -Name $TargetName
        Write-Host "[*] Connecting to running lab: $TargetName" -ForegroundColor Yellow
        docker exec -it $TargetName bash
    }
    "^stop$" {
        Check-Running -Name $TargetName
        Write-Host "[*] Stopping lab: $TargetName" -ForegroundColor Yellow
        docker stop $TargetName
    }
    "^status$" {
        Check-Running -Name $TargetName
        Write-Host "[*] Status: Container '$TargetName' is currently RUNNING." -ForegroundColor Green
    }
    "^logs$" {
        Check-Running -Name $TargetName
        Write-Host "[*] Fetching logs for: $TargetName" -ForegroundColor Yellow
        docker logs $TargetName
    }
    "^clean$" {
        $exists = (docker image inspect $IMAGE_FULL_NAME 2>$null)
        if (-not $exists) {
            Write-Host "Error: Image '$IMAGE_FULL_NAME' does not exist." -ForegroundColor Red
            exit 1
        }
        Write-Host "[*] Removing image '$IMAGE_FULL_NAME'..." -ForegroundColor Yellow
        docker rmi $IMAGE_FULL_NAME
    }
    "^(help|-h|--help)$" {
        Show-Help
    }
    default {
        Write-Host "Error: Invalid command '$Action'." -ForegroundColor Red
        exit 1
    }
}