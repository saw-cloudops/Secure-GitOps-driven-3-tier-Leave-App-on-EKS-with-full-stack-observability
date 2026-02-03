#!/usr/bin/env pwsh
# Test k3d Deployment

Write-Host "=== Testing k3d Deployment ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: Health endpoint
Write-Host "Test 1: Backend Health Check..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost/api/health" -Method GET -UseBasicParsing
    Write-Host "   ✓ Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   ✓ Response: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   → Check if pods are running: kubectl get pods -n leave-system" -ForegroundColor Yellow
}

Write-Host ""

# Test 2: Frontend
Write-Host "Test 2: Frontend Access..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost/" -Method GET -UseBasicParsing
    Write-Host "   ✓ Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   ✓ Frontend is accessible" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Register a test user
Write-Host "Test 3: User Registration..." -ForegroundColor Yellow
try {
    $body = @{
        username = "k3d_test_$(Get-Random)"
        password = "testpass123"
        role = "EMPLOYEE"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost/api/register" `
        -Method POST `
        -Body $body `
        -ContentType "application/json" `
        -UseBasicParsing

    Write-Host "   ✓ Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   ✓ Response: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   → Check backend logs: kubectl logs -l app=backend -n leave-system" -ForegroundColor Yellow
}

Write-Host ""

# Show pod status
Write-Host "Current Pod Status:" -ForegroundColor Cyan
kubectl get pods -n leave-system

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "If all tests pass, your k3d deployment is working!" -ForegroundColor Green
Write-Host "Open http://localhost in your browser to use the application." -ForegroundColor White
