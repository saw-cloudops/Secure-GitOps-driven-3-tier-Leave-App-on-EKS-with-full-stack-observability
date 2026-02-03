#!/usr/bin/env pwsh
# Cleanup k3d Cluster and Resources

Write-Host "=== k3d Cleanup ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "This will:" -ForegroundColor Yellow
Write-Host "  1. Delete the leave-system namespace (all deployments)" -ForegroundColor Gray
Write-Host "  2. Delete the k3d cluster 'lab-cluster'" -ForegroundColor Gray
Write-Host ""

$confirmation = Read-Host "Are you sure? (yes/no)"
if ($confirmation -ne "yes") {
    Write-Host "Cleanup cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""

# Delete namespace
Write-Host "Deleting namespace 'leave-system'..." -ForegroundColor Yellow
kubectl delete namespace leave-system --ignore-not-found=true
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✓ Namespace deleted" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Namespace may not exist" -ForegroundColor Yellow
}

Write-Host ""

# Delete cluster
Write-Host "Deleting k3d cluster 'lab-cluster'..." -ForegroundColor Yellow
k3d cluster delete lab-cluster
if ($LASTEXITCODE -eq 0) {
    Write-Host "   ✓ Cluster deleted" -ForegroundColor Green
} else {
    Write-Host "   ⚠ Cluster may not exist" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Cleanup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "To start fresh, run: .\k3d-setup.ps1" -ForegroundColor White
