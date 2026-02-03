#!/usr/bin/env pwsh
# Build and Import Docker Images to k3d

# Check if k3d is installed
Write-Host 'Checking prerequisites...' -ForegroundColor Cyan
if (-not (Get-Command k3d -ErrorAction SilentlyContinue)) {
    Write-Host ''
    Write-Host 'ERROR: k3d is not installed!' -ForegroundColor Red
    Write-Host ''
    Write-Host 'Please install k3d first:' -ForegroundColor Yellow
    Write-Host '  Using Chocolatey: choco install k3d' -ForegroundColor White
    Write-Host '  Using Scoop:      scoop install k3d' -ForegroundColor White
    Write-Host '  Manual download:  https://k3d.io/#installation' -ForegroundColor White
    Write-Host ''
    Write-Host 'After installation, restart PowerShell and run this script again.' -ForegroundColor Yellow
    exit 1
}

Write-Host '[OK] k3d is installed' -ForegroundColor Green
Write-Host ''

Write-Host '=== Building and Importing Docker Images to k3d ===' -ForegroundColor Cyan
Write-Host ''

# Step 1: Build Backend Image
Write-Host 'Step 1: Building backend image...' -ForegroundColor Yellow
docker build -t leave-backend:local ./backend
if ($LASTEXITCODE -eq 0) {
    Write-Host '   [OK] Backend image built successfully' -ForegroundColor Green
} else {
    Write-Host '   [FAIL] Failed to build backend image' -ForegroundColor Red
    exit 1
}

Write-Host ''

# Step 2: Build Frontend Image
Write-Host 'Step 2: Building frontend image...' -ForegroundColor Yellow
docker build -t leave-frontend:local ./frontend
if ($LASTEXITCODE -eq 0) {
    Write-Host '   [OK] Frontend image built successfully' -ForegroundColor Green
} else {
    Write-Host '   [FAIL] Failed to build frontend image' -ForegroundColor Red
    exit 1
}

Write-Host ''

# Step 3: Import Backend to k3d
Write-Host 'Step 3: Importing backend image to k3d cluster...' -ForegroundColor Yellow
k3d image import leave-backend:local -c lab-cluster
if ($LASTEXITCODE -eq 0) {
    Write-Host '   [OK] Backend image imported successfully' -ForegroundColor Green
} else {
    Write-Host '   [FAIL] Failed to import backend image' -ForegroundColor Red
    exit 1
}

Write-Host ''

# Step 4: Import Frontend to k3d
Write-Host 'Step 4: Importing frontend image to k3d cluster...' -ForegroundColor Yellow
k3d image import leave-frontend:local -c lab-cluster
if ($LASTEXITCODE -eq 0) {
    Write-Host '   [OK] Frontend image imported successfully' -ForegroundColor Green
} else {
    Write-Host '   [FAIL] Failed to import frontend image' -ForegroundColor Red
    exit 1
}

Write-Host ''
Write-Host '=== Images Ready ===' -ForegroundColor Cyan
Write-Host ''
Write-Host 'Next step: Deploy to k3d' -ForegroundColor Green
Write-Host 'Run: .\k3d-deploy.ps1' -ForegroundColor White