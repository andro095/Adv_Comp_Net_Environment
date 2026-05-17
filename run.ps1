<#
.SYNOPSIS
    Mininet Lab Manager Help
.DESCRIPTION
    This script automates building, running, and connecting to your Mininet Docker containers in PowerShell.
#>

param (
    [Parameter(Position=0)]
    [string]$Action = "help",

    [Parameter(Position=1)]
    [string]$LabName
)

function Show-Help {
    Write-Host "=== Mininet Lab Manager Help ===" -ForegroundColor Cyan
    Write-Host "This script automates building, running, and connecting to your Mininet Docker containers."
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\run.ps1 <command> [arguments]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  build            Builds the Docker image ('mymininet:latest') from the local Dockerfile."
    Write-Host "  run <lab-name>   Starts a container for the specified lab. Automatically mounts a"
    Write-Host "                   local output folder named '<lab-name>-output' to save your work."
    Write-Host "  exec <lab-name>  Opens a new bash shell inside an ALREADY RUNNING lab container."
    Write-Host "                   Useful for running secondary commands (like tcpdump) in a new tab."
    Write-Host "  help, -h, --help Shows this help menu."
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\run.ps1 build"
    Write-Host "  .\run.ps1 run lab-1"
    Write-Host "  .\run.ps1 exec lab-1"
    Write-Host "================================" -ForegroundColor Cyan
}

function Build-Image {
    Write-Host "[*] Building Docker image 'mymininet:latest'..." -ForegroundColor Yellow
    docker build -t mymininet:latest .
}

function Run-Lab {
    param([string]$Name)

    if ([string]::IsNullOrWhiteSpace($Name)) {
        Write-Host "Error: You must provide a lab name." -ForegroundColor Red
        Write-Host "Type '.\run.ps1 help' for usage instructions."
        exit 1
    }

    Write-Host "[*] Starting lab: $Name" -ForegroundColor Yellow

    # Get the current directory path and format it for Docker's volume mount
    $CurrentDir = $PWD.Path
    # Convert Windows backslashes to forward slashes for safer Docker compatibility
    $VolumeMount = "$CurrentDir\$Name-output:/home/student/$Name-output" -replace "\\", "/"
    
    Write-Host "[*] Detected Windows PowerShell environment. Using volume mount:" -ForegroundColor DarkGray
    Write-Host "    $VolumeMount" -ForegroundColor DarkGray

    # Execute the Docker run command
    docker run -it --rm --privileged --name "$Name" -v "$VolumeMount" mymininet:latest
}

function Exec-Lab {
    param([string]$Name)

    if ([string]::IsNullOrWhiteSpace($Name)) {
        Write-Host "Error: You must provide a lab name to connect to." -ForegroundColor Red
        Write-Host "Type '.\run.ps1 help' for usage instructions."
        exit 1
    }

    Write-Host "[*] Connecting to running lab: $Name" -ForegroundColor Yellow
    docker exec -it "$Name" bash
}

# Main command routing
switch -Regex ($Action.ToLower()) {
    "^build$" {
        Build-Image
    }
    "^run$" {
        Run-Lab -Name $LabName
    }
    "^exec$" {
        Exec-Lab -Name $LabName
    }
    "^(help|-h|--help)$" {
        Show-Help
    }
    default {
        Write-Host "Invalid command or no command provided." -ForegroundColor Red
        Write-Host "Type '.\run.ps1 help' for usage instructions."
        exit 1
    }
}