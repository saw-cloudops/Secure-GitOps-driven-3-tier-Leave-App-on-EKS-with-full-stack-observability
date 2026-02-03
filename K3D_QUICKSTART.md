# k3d Local Testing - Quick Start Guide

This guide provides a streamlined workflow for testing the Leave Management System locally using k3d.

## 🚀 Quick Start (3 Steps)

### Step 1: Install k3d
```powershell
.\k3d-install.ps1
```
This script will automatically install k3d using Chocolatey or Scoop if available.

**After installation, restart PowerShell!**

### Step 2: Create Cluster
```powershell
.\k3d-create-cluster.ps1
```
This creates a local Kubernetes cluster named `lab-cluster` with:
- 1 control plane node
- 2 worker nodes
- Port mappings for HTTP (80) and HTTPS (443)

### Step 3: Build & Deploy
```powershell
# Build and import Docker images
.\k3d-build-images.ps1

# Deploy the application
.\k3d-deploy.ps1
```

### Step 4: Access Application
Open your browser to:
```
http://localhost
```

## 📋 Prerequisites

- **Docker Desktop**: Must be installed and running
- **PowerShell**: Windows PowerShell or PowerShell Core
- **RAM**: At least 4GB available for Docker

## 📁 Scripts Overview

| Script | Purpose |
|--------|---------|
| `k3d-install.ps1` | Installs k3d using available package manager |
| `k3d-create-cluster.ps1` | Creates a local k3d cluster |
| `k3d-build-images.ps1` | Builds and imports Docker images |
| `k3d-deploy.ps1` | Deploys the application to k3d |

## 🐳 Docker Image Optimizations

Both backend and frontend use **multi-stage builds** for optimal size:

### Backend
- **Before**: ~200-250 MB (with dev dependencies)
- **After**: ~80-120 MB (production only)
- **Improvements**:
  - Only production dependencies
  - Non-root user for security
  - Smaller attack surface

### Frontend
- **Before**: ~400-500 MB (with Node.js)
- **After**: ~30-50 MB (nginx only)
- **Improvements**:
  - Static files only
  - No Node.js runtime
  - Fast startup

See [DOCKER_OPTIMIZATION.md](./DOCKER_OPTIMIZATION.md) for details.

## 🔧 Common Commands

### Cluster Management
```powershell
# List clusters
k3d cluster list

# Stop cluster
k3d cluster stop lab-cluster

# Start cluster
k3d cluster start lab-cluster

# Delete cluster
k3d cluster delete lab-cluster
```

### Kubernetes Commands
```powershell
# Get all resources
kubectl get all -A

# Get pods
kubectl get pods

# View logs
kubectl logs <pod-name>

# Describe pod
kubectl describe pod <pod-name>

# Get events
kubectl get events --sort-by='.lastTimestamp'
```

### Image Management
```powershell
# List Docker images
docker images | findstr leave

# Rebuild single image
docker build -t leave-backend:local ./backend
docker build -t leave-frontend:local ./frontend

# Import to k3d
k3d image import leave-backend:local -c lab-cluster
k3d image import leave-frontend:local -c lab-cluster
```

## 🐛 Troubleshooting

### k3d command not found
**Solution**: Restart PowerShell after installation to refresh PATH.

### Docker daemon not running
**Solution**: Start Docker Desktop and wait for it to be fully running.

### Port 80 already in use
**Solution**: 
```powershell
# Check what's using port 80
netstat -ano | findstr :80

# Or create cluster with different port
k3d cluster create lab-cluster --port "8080:80@loadbalancer"
```

### Pods not starting
**Solution**:
```powershell
# Check pod status
kubectl get pods -A

# View pod logs
kubectl logs <pod-name>

# Describe pod for details
kubectl describe pod <pod-name>
```

### Images not importing
**Solution**:
```powershell
# Rebuild images
docker build -t leave-backend:local ./backend
docker build -t leave-frontend:local ./frontend

# Manually import
k3d image import leave-backend:local -c lab-cluster
k3d image import leave-frontend:local -c lab-cluster
```

## 🧹 Clean Up

When you're done testing:

```powershell
# Delete the cluster
k3d cluster delete lab-cluster

# Remove Docker images (optional)
docker rmi leave-backend:local leave-frontend:local
```

## 📚 Additional Documentation

- [K3D_SETUP.md](./K3D_SETUP.md) - Detailed setup guide
- [DOCKER_OPTIMIZATION.md](./DOCKER_OPTIMIZATION.md) - Image optimization details

## 🔄 Workflow Diagram

```
┌─────────────────────┐
│  Install k3d        │
│  k3d-install.ps1    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Create Cluster     │
│  k3d-create-        │
│  cluster.ps1        │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Build Images       │
│  k3d-build-         │
│  images.ps1         │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Deploy App         │
│  k3d-deploy.ps1     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Access at          │
│  http://localhost   │
└─────────────────────┘
```

## ✅ Verification Checklist

After deployment, verify:

- [ ] Cluster is running: `k3d cluster list`
- [ ] Nodes are ready: `kubectl get nodes`
- [ ] Pods are running: `kubectl get pods`
- [ ] Services are available: `kubectl get svc`
- [ ] Application is accessible: `http://localhost`
- [ ] Database is connected (check backend logs)
- [ ] Can login as employee
- [ ] Can login as admin
- [ ] Can submit leave request
- [ ] Admin can approve/reject leave

## 🎯 Next Steps

After successful local testing:

1. ✅ Verify all features work correctly
2. ✅ Test database connectivity
3. ✅ Review application logs
4. ✅ Test ingress routing
5. ✅ Prepare for AWS EKS deployment

## 📞 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review [K3D_SETUP.md](./K3D_SETUP.md) for detailed information
3. Check k3d documentation: https://k3d.io/
4. Check Kubernetes documentation: https://kubernetes.io/docs/

## 🔗 Resources

- [k3d Documentation](https://k3d.io/)
- [k3s Documentation](https://k3s.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
