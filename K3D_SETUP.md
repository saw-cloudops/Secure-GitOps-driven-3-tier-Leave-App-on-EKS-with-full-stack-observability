# k3d Local Testing Setup Guide

This guide will help you set up k3d for local Kubernetes testing of the Leave Management System.

## Prerequisites

- Docker Desktop installed and running
- PowerShell (Windows)
- At least 4GB RAM available for Docker

## Step 1: Install k3d

Choose one of the following methods:

### Option A: Using Chocolatey (Recommended for Windows)

```powershell
# Install Chocolatey if not already installed
# Run as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install k3d
choco install k3d -y
```

### Option B: Using Scoop

```powershell
# Install Scoop if not already installed
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

# Install k3d
scoop install k3d
```

### Option C: Manual Installation

1. Download the latest k3d release from: https://github.com/k3d-io/k3d/releases
2. Extract the executable
3. Add it to your PATH

### Verify Installation

```powershell
k3d version
```

You should see output showing the k3d version.

## Step 2: Create k3d Cluster

Create a local Kubernetes cluster named `lab-cluster`:

```powershell
# Create cluster with port mappings for HTTP/HTTPS
k3d cluster create lab-cluster `
  --api-port 6550 `
  --servers 1 `
  --agents 2 `
  --port "80:80@loadbalancer" `
  --port "443:443@loadbalancer"
```

**What this does:**
- Creates a cluster named `lab-cluster`
- 1 server node (control plane)
- 2 agent nodes (worker nodes)
- Maps ports 80 and 443 for ingress access

### Verify Cluster

```powershell
# Check cluster status
k3d cluster list

# Get cluster info
kubectl cluster-info

# Check nodes
kubectl get nodes
```

## Step 3: Build and Import Docker Images

Now you can run the build script:

```powershell
.\k3d-build-images.ps1
```

This script will:
1. ✅ Check if k3d is installed
2. 🔨 Build optimized backend Docker image (multi-stage)
3. 🔨 Build optimized frontend Docker image (multi-stage)
4. 📦 Import backend image to k3d cluster
5. 📦 Import frontend image to k3d cluster

### Image Size Optimization

The Dockerfiles now use **multi-stage builds** to minimize image size:

#### Backend Optimization:
- **Stage 1 (dependencies)**: Installs only production dependencies
- **Stage 2 (production)**: Copies only node_modules and app code
- **Benefits**: 
  - Removes devDependencies (jest, supertest, etc.)
  - Smaller image size (~50-70% reduction)
  - Faster deployments
  - Enhanced security (non-root user)

#### Frontend Optimization:
- **Stage 1 (builder)**: Builds the React/Vite app
- **Stage 2 (nginx)**: Serves static files with nginx:alpine
- **Benefits**:
  - No Node.js in final image
  - Only static files served by nginx
  - Minimal image size (~90% reduction)

## Step 4: Deploy to k3d

Deploy the application:

```powershell
.\k3d-deploy.ps1
```

## Step 5: Access the Application

Once deployed, access the application:

```
http://localhost
```

## Useful k3d Commands

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

### Image Management

```powershell
# Import a single image
k3d image import <image-name>:tag -c lab-cluster

# List images in cluster
docker exec k3d-lab-cluster-server-0 crictl images
```

### Debugging

```powershell
# Get all resources
kubectl get all -A

# Check pod logs
kubectl logs <pod-name> -n default

# Describe pod
kubectl describe pod <pod-name> -n default

# Get events
kubectl get events -n default --sort-by='.lastTimestamp'
```

## Troubleshooting

### Issue: k3d command not found after installation

**Solution**: Restart PowerShell or your terminal to refresh the PATH.

### Issue: Docker daemon not running

**Solution**: Start Docker Desktop and wait for it to be fully running.

### Issue: Port already in use

**Solution**: 
```powershell
# Check what's using the port
netstat -ano | findstr :80

# Kill the process or use different ports when creating cluster
k3d cluster create lab-cluster --port "8080:80@loadbalancer"
```

### Issue: Images not importing

**Solution**:
```powershell
# Rebuild images
docker build -t leave-backend:local ./backend
docker build -t leave-frontend:local ./frontend

# Manually import
k3d image import leave-backend:local -c lab-cluster
k3d image import leave-frontend:local -c lab-cluster
```

### Issue: Pods not starting

**Solution**:
```powershell
# Check pod status
kubectl get pods -A

# Check pod logs
kubectl logs <pod-name> -n default

# Describe pod for events
kubectl describe pod <pod-name> -n default
```

## Clean Up

When you're done testing:

```powershell
# Delete the cluster
k3d cluster delete lab-cluster

# Remove Docker images (optional)
docker rmi leave-backend:local leave-frontend:local
```

## Next Steps

After successful local testing:
1. Test all application features
2. Verify database connectivity
3. Test ingress routing
4. Review logs and metrics
5. Prepare for AWS EKS deployment

## Additional Resources

- [k3d Documentation](https://k3d.io/)
- [k3s Documentation](https://k3s.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
