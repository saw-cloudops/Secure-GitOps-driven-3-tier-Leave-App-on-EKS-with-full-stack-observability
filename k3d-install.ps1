#!/usr/bin/env pwsh
# k3d Installation Script for Windows

Write-Host "=== k3d Installation Script ===" -ForegroundColor Cyan
Write-Host ""

# Check if k3d is already installed
if (Get-Command k3d -ErrorAction SilentlyContinue) {
    $version = k3d version
    Write-Host "✓ k3d is already installed!" -ForegroundColor Green
    Write-Host "$version" -ForegroundColor White
    Write-Host ""
    Write-Host "You can proceed to create a cluster:" -ForegroundColor Yellow
    Write-Host "  .\k3d-create-cluster.ps1" -ForegroundColor White
    exit 0
}

Write-Host "k3d is not installed. Let's install it!" -ForegroundColor Yellow
Write-Host ""

# Check for package managers
$hasChoco = Get-Command choco -ErrorAction SilentlyContinue
$hasScoop = Get-Command scoop -ErrorAction SilentlyContinue

if ($hasChoco) {
    Write-Host "Found Chocolatey package manager" -ForegroundColor Green
    Write-Host "Installing k3d via Chocolatey..." -ForegroundColor Yellow
    Write-Host ""
    
    choco install k3d -y
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✓ k3d installed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Please restart PowerShell and verify installation:" -ForegroundColor Yellow
        Write-Host "  k3d version" -ForegroundColor White
        Write-Host ""
        Write-Host "Then create a cluster:" -ForegroundColor Yellow
        Write-Host "  .\k3d-create-cluster.ps1" -ForegroundColor White
    } else {
        Write-Host "✗ Installation failed" -ForegroundColor Red
        exit 1
    }
} elseif ($hasScoop) {
    Write-Host "Found Scoop package manager" -ForegroundColor Green
    Write-Host "Installing k3d via Scoop..." -ForegroundColor Yellow
    Write-Host ""
    
    scoop install k3d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✓ k3d installed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Please restart PowerShell and verify installation:" -ForegroundColor Yellow
        Write-Host "  k3d version" -ForegroundColor White
        Write-Host ""
        Write-Host "Then create a cluster:" -ForegroundColor Yellow
        Write-Host "  .\k3d-create-cluster.ps1" -ForegroundColor White
    } else {
        Write-Host "✗ Installation failed" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "No package manager found (Chocolatey or Scoop)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please choose an installation method:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Option 1: Install via Chocolatey (Recommended)" -ForegroundColor Yellow
    Write-Host "  1. Install Chocolatey (run as Administrator):" -ForegroundColor White
    Write-Host "     Set-ExecutionPolicy Bypass -Scope Process -Force;" -ForegroundColor Gray
    Write-Host "     [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;" -ForegroundColor Gray
    Write-Host "     iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. Then install k3d:" -ForegroundColor White
    Write-Host "     choco install k3d -y" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Option 2: Install via Scoop" -ForegroundColor Yellow
    Write-Host "  1. Install Scoop:" -ForegroundColor White
    Write-Host "     Set-ExecutionPolicy RemoteSigned -Scope CurrentUser" -ForegroundColor Gray
    Write-Host "     irm get.scoop.sh | iex" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  2. Then install k3d:" -ForegroundColor White
    Write-Host "     scoop install k3d" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Option 3: Manual Installation" -ForegroundColor Yellow
    Write-Host "  Download from: https://github.com/k3d-io/k3d/releases" -ForegroundColor White
    Write-Host ""
}
