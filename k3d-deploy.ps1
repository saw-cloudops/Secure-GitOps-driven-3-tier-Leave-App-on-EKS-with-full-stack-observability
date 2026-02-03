#!/usr/bin/env pwsh
# Deploy Application to k3d Cluster

Write-Host '=== Deploying Leave System to k3d ===' -ForegroundColor Cyan
Write-Host ''

# Verify cluster is running
Write-Host 'Verifying k3d cluster...' -ForegroundColor Yellow
$clusterStatus = k3d cluster list | Select-String 'lab-cluster'
if (-not $clusterStatus) {
    Write-Host '   [FAIL] k3d cluster lab-cluster not found' -ForegroundColor Red
    Write-Host '   Run: .\k3d-setup.ps1 first' -ForegroundColor Yellow
    exit 1
}
Write-Host '   [OK] Cluster is running' -ForegroundColor Green
Write-Host ''

# Step 1: Create namespace and secrets
Write-Host 'Step 1: Creating namespace and secrets...' -ForegroundColor Yellow
kubectl apply -f k3d/secrets.yaml
if ($LASTEXITCODE -eq 0) {
    Write-Host '   [OK] Secrets created' -ForegroundColor Green
} else {
    Write-Host '   [FAIL] Failed to create secrets' -ForegroundColor Red
    exit 1
}

Write-Host ''

# Step 2: Deploy MySQL
Write-Host 'Step 2: Deploying MySQL...' -ForegroundColor Yellow
kubectl apply -f k3d/mysql.yaml
if ($LASTEXITCODE -eq 0) {
    Write-Host '   [OK] MySQL deployed' -ForegroundColor Green
} else {
    Write-Host '   [FAIL] Failed to deploy MySQL' -ForegroundColor Red
    exit 1
}

Write-Host '   Waiting for MySQL to be ready...' -ForegroundColor Gray
kubectl wait --for=condition=ready pod -l app=mysql -n leave-system --timeout=120s
if ($LASTEXITCODE -eq 0) {
    Write-Host '   [OK] MySQL is ready' -ForegroundColor Green
} else {
    Write-Host '   [WARN] MySQL may not be ready yet, continuing anyway...' -ForegroundColor Yellow
}

Write-Host ''

# Step 3: Deploy Backend
Write-Host 'Step 3: Deploying Backend...' -ForegroundColor Yellow
kubectl apply -f k3d/backend.yaml
if ($LASTEXITCODE -eq 0) {
    Write-Host '   [OK] Backend deployed' -ForegroundColor Green
} else {
    Write-Host '   [FAIL] Failed to deploy Backend' -ForegroundColor Red
    exit 1
}

Write-Host '   Waiting for Backend to be ready...' -ForegroundColor Gray
kubectl wait --for=condition=ready pod -l app=backend -n leave-system --timeout=120s
if ($LASTEXITCODE -eq 0) {
    Write-Host '   [OK] Backend is ready' -ForegroundColor Green
} else {
    Write-Host '   [WARN] Backend may not be ready yet, continuing anyway...' -ForegroundColor Yellow
}

Write-Host ''

# Step 4: Deploy Frontend
Write-Host 'Step 4: Deploying Frontend...' -ForegroundColor Yellow
kubectl apply -f k3d/frontend.yaml
if ($LASTEXITCODE -eq 0) {
    Write-Host '   [OK] Frontend deployed' -ForegroundColor Green
} else {
    Write-Host '   [FAIL] Failed to deploy Frontend' -ForegroundColor Red
    exit 1
}

Write-Host '   Waiting for Frontend to be ready...' -ForegroundColor Gray
kubectl wait --for=condition=ready pod -l app=frontend -n leave-system --timeout=120s
if ($LASTEXITCODE -eq 0) {
    Write-Host '   [OK] Frontend is ready' -ForegroundColor Green
} else {
    Write-Host '   [WARN] Frontend may not be ready yet, continuing anyway...' -ForegroundColor Yellow
}

Write-Host ''

# Step 5: Deploy Ingress
Write-Host 'Step 5: Deploying Ingress...' -ForegroundColor Yellow
kubectl apply -f k3d/ingress.yaml
if ($LASTEXITCODE -eq 0) {
    Write-Host '   [OK] Ingress deployed' -ForegroundColor Green
} else {
    Write-Host '   [FAIL] Failed to deploy Ingress' -ForegroundColor Red
    exit 1
}

Write-Host ''

# Step 6: Show deployment status
Write-Host 'Step 6: Checking deployment status...' -ForegroundColor Yellow
Write-Host ''
Write-Host 'Pods:' -ForegroundColor Cyan
kubectl get pods -n leave-system

Write-Host ''
Write-Host 'Services:' -ForegroundColor Cyan
kubectl get svc -n leave-system

Write-Host ''
Write-Host 'Ingress:' -ForegroundColor Cyan
kubectl get ingress -n leave-system

Write-Host ''
Write-Host '=== Deployment Complete ===' -ForegroundColor Cyan
Write-Host ''
Write-Host 'Access your application:' -ForegroundColor Green
Write-Host '  Frontend: http://localhost' -ForegroundColor White
Write-Host '  Backend API: http://localhost/api/health' -ForegroundColor White
Write-Host ''
Write-Host 'Useful commands:' -ForegroundColor Yellow
Write-Host '  View logs (backend): kubectl logs -l app=backend -n leave-system -f' -ForegroundColor Gray
Write-Host '  View logs (frontend): kubectl logs -l app=frontend -n leave-system -f' -ForegroundColor Gray
Write-Host '  View logs (mysql): kubectl logs -l app=mysql -n leave-system -f' -ForegroundColor Gray
Write-Host '  Get all resources: kubectl get all -n leave-system' -ForegroundColor Gray
Write-Host '  Delete deployment: kubectl delete namespace leave-system' -ForegroundColor Gray
Write-Host ''
Write-Host 'Test the application:' -ForegroundColor Green
Write-Host '  curl http://localhost/api/health' -ForegroundColor White