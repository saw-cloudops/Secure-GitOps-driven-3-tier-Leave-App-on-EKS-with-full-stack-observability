#!/usr/bin/env pwsh
# k3d Local Kubernetes Setup Script

Write-Host "=== k3d Local Kubernetes Setup ===" -ForegroundColor Cyan
Write-Host ""

# Step 1: Install k3d
Write-Host "Step 1: Installing k3d..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh" -UseBasicParsing
    $response.Content | bash
    Write-Host "   ✓ k3d installed successfully" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed to install k3d: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   → Try manual installation: https://k3d.io/v5.6.0/#installation" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Step 2: Create k3d cluster
Write-Host "Step 2: Creating k3d cluster 'lab-cluster'..." -ForegroundColor Yellow
Write-Host "   This will create:" -ForegroundColor Gray
Write-Host "   - 1 server node (control plane)" -ForegroundColor Gray
Write-Host "   - 3 agent nodes (workers)" -ForegroundColor Gray
Write-Host "   - Port mappings: 80, 443, 8080" -ForegroundColor Gray
Write-Host ""

k3d cluster create lab-cluster `
  --servers 1 `
  --agents 3 `
  --port "8080:80@loadbalancer" `
  --port "8443:443@loadbalancer" `
  --port "80:80@loadbalancer"

if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✓ Cluster created successfully" -ForegroundColor Green
} else {
    Write-Host "   ✗ Failed to create cluster" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 3: Verify cluster
Write-Host "Step 3: Verifying cluster..." -ForegroundColor Yellow
kubectl cluster-info
kubectl get nodes

Write-Host ""
Write-Host "=== k3d Setup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Green
Write-Host "1. Build Docker images: .\k3d-build-images.ps1" -ForegroundColor White
Write-Host "2. Deploy application: .\k3d-deploy.ps1" -ForegroundColor White
Write-Host "3. Access application: http://localhost" -ForegroundColor White
Write-Host ""
Write-Host "To delete cluster: k3d cluster delete lab-cluster" -ForegroundColor Gray
