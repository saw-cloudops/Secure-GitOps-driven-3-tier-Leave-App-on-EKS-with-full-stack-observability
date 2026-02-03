#!/usr/bin/env pwsh
# Install Logging Stack (Loki + Promtail)

Write-Host "=== Installing Logging Stack ===" -ForegroundColor Cyan
Write-Host ""

# Determine Helm Command
$HELM = "helm"
if (Test-Path ".\helm.exe") {
    $HELM = ".\helm.exe"
}

# 1. Add Repo
Write-Host "Updating Grafana repo..." -ForegroundColor Yellow
& $HELM repo add grafana https://grafana.github.io/helm-charts
& $HELM repo update

# 2. Install Loki Stack
Write-Host "Installing Loki + Promtail (Local Filesystem)..." -ForegroundColor Yellow
& $HELM upgrade --install loki grafana/loki-stack `
  --namespace monitoring `
  -f monitoring/values-loki-local.yaml `
  --set grafana.enabled=false `
  --set prometheus.enabled=false `
  --set fluent-bit.enabled=false `
  --wait

if ($LASTEXITCODE -eq 0) {
    Write-Host "   [OK] Loki & Promtail installed" -ForegroundColor Green
} else {
    Write-Host "   [FAIL] Failed to install Loki Stack" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Logging Setup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Action Required: Add Loki Data Source in Grafana" -ForegroundColor Yellow
Write-Host "1. Open Grafana: http://localhost:3000" -ForegroundColor White
Write-Host "2. Connections -> Add Data Source -> Loki" -ForegroundColor White
Write-Host "3. URL: http://loki:3100" -ForegroundColor White
Write-Host "4. Click 'Save & test'" -ForegroundColor White
Write-Host ""
Write-Host "View Logs:" -ForegroundColor Yellow
Write-Host "Explore -> Loki -> Label Filters: {app=`"backend`"}" -ForegroundColor Gray
