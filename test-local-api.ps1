#!/usr/bin/env pwsh
# Test script to verify local API endpoints

Write-Host "=== Testing Local API Endpoints ===" -ForegroundColor Cyan
Write-Host ""

# Test backend health endpoint
Write-Host "1. Testing Backend Health (http://localhost:3000/health)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -Method GET -UseBasicParsing
    Write-Host "   ✓ Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   ✓ Response: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   → Make sure backend is running: cd backend && node app.js" -ForegroundColor Yellow
}

Write-Host ""

# Test backend API health endpoint
Write-Host "2. Testing Backend API Health (http://localhost:3000/api/health)..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -Method GET -UseBasicParsing
    Write-Host "   ✓ Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   ✓ Response: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test register endpoint
Write-Host "3. Testing Register Endpoint (POST http://localhost:3000/api/register)..." -ForegroundColor Yellow
try {
    $body = @{
        username = "testuser_$(Get-Random)"
        password = "testpass123"
        role = "EMPLOYEE"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/register" `
        -Method POST `
        -Body $body `
        -ContentType "application/json" `
        -UseBasicParsing

    Write-Host "   ✓ Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   ✓ Response: $($response.Content)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   → Make sure MySQL is running and database is initialized" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Test Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "If all tests pass, your local setup is working correctly!" -ForegroundColor Green
Write-Host "The same API structure will work in EKS with the Ingress routing." -ForegroundColor Green
