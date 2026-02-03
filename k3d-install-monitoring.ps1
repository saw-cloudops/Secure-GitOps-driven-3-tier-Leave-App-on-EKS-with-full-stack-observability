#!/usr/bin/env pwsh
# Install Monitoring Stack (Prometheus, Grafana, Tempo)

Write-Host "=== Installing Monitoring Stack ===" -ForegroundColor Cyan
Write-Host ""

# Determine Helm Command
$HELM = "helm"
if (Test-Path ".\helm.exe") {
    $HELM = ".\helm.exe"
    Write-Host "Using local helm binary: $HELM" -ForegroundColor Green
} elseif (-not (Get-Command helm -ErrorAction SilentlyContinue)) {
    Write-Host "Helm not found in path." -ForegroundColor Red
    Write-Host "Please ensure helm.exe is in the current directory or PATH." -ForegroundColor Yellow
    exit 1
}

# 2. Add Repos
Write-Host "Adding Helm repositories..." -ForegroundColor Yellow
& $HELM repo add prometheus-community https://prometheus-community.github.io/helm-charts
& $HELM repo add grafana https://grafana.github.io/helm-charts
& $HELM repo update
Write-Host "   [OK] Repos updated" -ForegroundColor Green

# 3. Install Prometheus Stack (Prometheus + Grafana + Alertmanager)
Write-Host "Installing kube-prometheus-stack..." -ForegroundColor Yellow
# Using release name 'prometheus' so it matches the label 'release: prometheus' in ServiceMonitors
& $HELM upgrade --install prometheus prometheus-community/kube-prometheus-stack `
  --namespace monitoring --create-namespace `
  -f monitoring/values-prometheus.yaml `
  --wait

if ($LASTEXITCODE -eq 0) {
    Write-Host "   [OK] Prometheus Stack installed" -ForegroundColor Green
} else {
    Write-Host "   [FAIL] Failed to install Prometheus Stack" -ForegroundColor Red
    exit 1
}

# 4. Install Grafana Tempo (Tracing)
Write-Host "Installing Grafana Tempo..." -ForegroundColor Yellow
& $HELM upgrade --install tempo grafana/tempo `
  --namespace monitoring `
  --set receiver.otlp.protocols.http.endpoint="0.0.0.0:4318" `
  --set receiver.otlp.protocols.grpc.endpoint="0.0.0.0:4317"

if ($LASTEXITCODE -eq 0) {
    Write-Host "   [OK] Tempo installed" -ForegroundColor Green
} else {
    Write-Host "   [FAIL] Failed to install Tempo" -ForegroundColor Red
    exit 1
}

# 5. Apply Service Monitors
Write-Host "Applying Service Monitors..." -ForegroundColor Yellow
kubectl apply -f monitoring/service-monitors.yaml
if ($LASTEXITCODE -eq 0) {
    Write-Host "   [OK] Service Monitors applied" -ForegroundColor Green
} else {
    Write-Host "   [FAIL] Failed to apply Service Monitors" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Monitoring Setup Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Accessing Grafana:" -ForegroundColor Yellow
Write-Host "1. Get Admin Password:" -ForegroundColor White
Write-Host "   kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath='{.data.admin-password}' | base64 -d" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Port Forward:" -ForegroundColor White
Write-Host "   kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Open Browser:" -ForegroundColor White
Write-Host "   http://localhost:3000 (User: admin)" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Configure Tempo in Grafana:" -ForegroundColor White
Write-Host "   Datasources -> Add -> Tempo -> URL: http://tempo.monitoring.svc.cluster.local:3200" -ForegroundColor Gray
