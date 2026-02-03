#!/usr/bin/env pwsh
# Create k3d Cluster for Leave Management System

Write-Host "=== Creating k3d Cluster ===" -ForegroundColor Cyan
Write-Host ""

# Check if k3d is installed
if (-not (Get-Command k3d -ErrorAction SilentlyContinue)) {
    Write-Host "❌ ERROR: k3d is not installed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Run the installation script first:" -ForegroundColor Yellow
    Write-Host "  .\k3d-install.ps1" -ForegroundColor White
    exit 1
}

# Check if Docker is running
Write-Host "Checking Docker..." -ForegroundColor Yellow
docker info > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ ERROR: Docker is not running!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please start Docker Desktop and try again." -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ Docker is running" -ForegroundColor Green
Write-Host ""

# Check if cluster already exists
$clusterName = "lab-cluster"
$existingCluster = k3d cluster list | Select-String $clusterName

if ($existingCluster) {
    Write-Host "⚠ Cluster '$clusterName' already exists!" -ForegroundColor Yellow
    Write-Host ""
    $response = Read-Host "Do you want to delete and recreate it? (y/N)"
    
    if ($response -eq 'y' -or $response -eq 'Y') {
        Write-Host ""
        Write-Host "Deleting existing cluster..." -ForegroundColor Yellow
        k3d cluster delete $clusterName
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "✗ Failed to delete cluster" -ForegroundColor Red
            exit 1
        }
        Write-Host "✓ Cluster deleted" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "Keeping existing cluster. You can proceed to build images:" -ForegroundColor Green
        Write-Host "  .\k3d-build-images.ps1" -ForegroundColor White
        exit 0
    }
}

# Create cluster
Write-Host "Creating k3d cluster '$clusterName'..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Configuration:" -ForegroundColor Cyan
Write-Host "  - Name: $clusterName" -ForegroundColor White
Write-Host "  - Servers: 1 (control plane)" -ForegroundColor White
Write-Host "  - Agents: 2 (worker nodes)" -ForegroundColor White
Write-Host "  - API Port: 6550" -ForegroundColor White
Write-Host "  - HTTP Port: 80" -ForegroundColor White
Write-Host "  - HTTPS Port: 443" -ForegroundColor White
Write-Host ""

k3d cluster create $clusterName `
    --api-port 6550 `
    --servers 1 `
    --agents 2 `
    --port "80:80@loadbalancer" `
    --port "443:443@loadbalancer" `
    --wait

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "✗ Failed to create cluster" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  - Ensure Docker has enough resources (4GB+ RAM)" -ForegroundColor White
    Write-Host "  - Check if ports 80, 443, 6550 are available" -ForegroundColor White
    Write-Host "  - Try: netstat -ano | findstr :80" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "✓ Cluster created successfully!" -ForegroundColor Green
Write-Host ""

# Verify cluster
Write-Host "Verifying cluster..." -ForegroundColor Yellow
Write-Host ""

Write-Host "Cluster Info:" -ForegroundColor Cyan
k3d cluster list

Write-Host ""
Write-Host "Nodes:" -ForegroundColor Cyan
kubectl get nodes

Write-Host ""
Write-Host "=== Cluster Ready ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Build and import Docker images:" -ForegroundColor White
Write-Host "     .\k3d-build-images.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Deploy the application:" -ForegroundColor White
Write-Host "     .\k3d-deploy.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Access the application:" -ForegroundColor White
Write-Host "     http://localhost" -ForegroundColor Gray
Write-Host ""

# Save cluster info
Write-Host "Useful commands:" -ForegroundColor Cyan
Write-Host "  Stop cluster:   k3d cluster stop $clusterName" -ForegroundColor White
Write-Host "  Start cluster:  k3d cluster start $clusterName" -ForegroundColor White
Write-Host "  Delete cluster: k3d cluster delete $clusterName" -ForegroundColor White
Write-Host "  View logs:      kubectl logs -f <pod-name>" -ForegroundColor White
Write-Host "  Get pods:       kubectl get pods -A" -ForegroundColor White
Write-Host ""
