#!/usr/bin/env pwsh
# Compare Docker Image Sizes - Before and After Optimization

Write-Host "=== Docker Image Size Comparison ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script will demonstrate the size reduction from Docker optimization" -ForegroundColor Yellow
Write-Host ""

# Check current images
Write-Host "Current Docker images:" -ForegroundColor Cyan
docker images | Select-String "leave-" | ForEach-Object {
    Write-Host $_ -ForegroundColor White
}

Write-Host ""
Write-Host "Building optimized images..." -ForegroundColor Yellow
Write-Host ""

# Build backend
Write-Host "Building backend (optimized multi-stage)..." -ForegroundColor Yellow
$backendStart = Get-Date
docker build -t leave-backend:optimized ./backend --quiet
$backendEnd = Get-Date
$backendTime = ($backendEnd - $backendStart).TotalSeconds

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Backend built successfully in $([math]::Round($backendTime, 2))s" -ForegroundColor Green
} else {
    Write-Host "✗ Backend build failed" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Build frontend
Write-Host "Building frontend (optimized multi-stage)..." -ForegroundColor Yellow
$frontendStart = Get-Date
docker build -t leave-frontend:optimized ./frontend --quiet
$frontendEnd = Get-Date
$frontendTime = ($frontendEnd - $frontendStart).TotalSeconds

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Frontend built successfully in $([math]::Round($frontendTime, 2))s" -ForegroundColor Green
} else {
    Write-Host "✗ Frontend build failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Image Size Comparison ===" -ForegroundColor Cyan
Write-Host ""

# Get image sizes
$backendSize = docker images leave-backend:optimized --format "{{.Size}}"
$frontendSize = docker images leave-frontend:optimized --format "{{.Size}}"

Write-Host "Optimized Images:" -ForegroundColor Green
Write-Host "  Backend:  $backendSize" -ForegroundColor White
Write-Host "  Frontend: $frontendSize" -ForegroundColor White
Write-Host ""

Write-Host "Comparison to typical sizes:" -ForegroundColor Yellow
Write-Host "  Backend:" -ForegroundColor Cyan
Write-Host "    Before (with dev deps): ~200-250 MB" -ForegroundColor Red
Write-Host "    After (optimized):      $backendSize" -ForegroundColor Green
Write-Host ""
Write-Host "  Frontend:" -ForegroundColor Cyan
Write-Host "    Before (with Node.js):  ~400-500 MB" -ForegroundColor Red
Write-Host "    After (nginx only):     $frontendSize" -ForegroundColor Green
Write-Host ""

# Show detailed image info
Write-Host "=== Detailed Image Information ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backend Image:" -ForegroundColor Yellow
docker images leave-backend:optimized --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}\t{{.CreatedAt}}"
Write-Host ""

Write-Host "Frontend Image:" -ForegroundColor Yellow
docker images leave-frontend:optimized --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}\t{{.CreatedAt}}"
Write-Host ""

# Show layer information
Write-Host "=== Layer Information ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Backend Layers (top 10):" -ForegroundColor Yellow
docker history leave-backend:optimized --format "table {{.Size}}\t{{.CreatedBy}}" --no-trunc | Select-Object -First 11
Write-Host ""

Write-Host "Frontend Layers (top 10):" -ForegroundColor Yellow
docker history leave-frontend:optimized --format "table {{.Size}}\t{{.CreatedBy}}" --no-trunc | Select-Object -First 11
Write-Host ""

# Tag as local for k3d
Write-Host "Tagging images for k3d..." -ForegroundColor Yellow
docker tag leave-backend:optimized leave-backend:local
docker tag leave-frontend:optimized leave-frontend:local

Write-Host "✓ Images tagged as 'local' for k3d import" -ForegroundColor Green
Write-Host ""

Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Optimized images built successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Key Improvements:" -ForegroundColor Yellow
Write-Host "  ✓ Multi-stage builds implemented" -ForegroundColor Green
Write-Host "  ✓ Production dependencies only" -ForegroundColor Green
Write-Host "  ✓ Non-root user (backend)" -ForegroundColor Green
Write-Host "  ✓ Minimal attack surface" -ForegroundColor Green
Write-Host "  ✓ Faster deployments" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Import to k3d: .\k3d-build-images.ps1" -ForegroundColor White
Write-Host "  2. Deploy: .\k3d-deploy.ps1" -ForegroundColor White
Write-Host ""
