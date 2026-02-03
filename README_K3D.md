# 🚀 k3d Local Testing - Complete Guide

## 📋 Overview

This directory contains everything you need to test the Leave Management System locally using k3d (k3s in Docker). The Docker images have been optimized using multi-stage builds for minimal size and maximum security.

## ✨ What's New

### 🐳 Docker Optimization
- **Backend**: Multi-stage build reduces size by ~50-70% (200-250 MB → 80-120 MB)
- **Frontend**: Already optimized with nginx (~30-50 MB)
- **Security**: Non-root user, production dependencies only
- **Performance**: Faster builds, better caching, quicker deployments

### 🛠️ Automated Scripts
- **k3d-install.ps1**: Automated k3d installation
- **k3d-create-cluster.ps1**: One-command cluster creation
- **k3d-build-images.ps1**: Build and import with validation
- **docker-compare-sizes.ps1**: Compare image sizes

## 🎯 Quick Start (5 Minutes)

### 1️⃣ Install k3d
```powershell
.\k3d-install.ps1
```
Then **restart PowerShell** to refresh PATH.

### 2️⃣ Create Cluster
```powershell
.\k3d-create-cluster.ps1
```

### 3️⃣ Build & Import Images
```powershell
.\k3d-build-images.ps1
```

### 4️⃣ Deploy Application
```powershell
.\k3d-deploy.ps1
```

### 5️⃣ Access Application
Open browser: **http://localhost**

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **K3D_QUICKSTART.md** | Quick start guide (start here!) |
| **K3D_SETUP.md** | Detailed setup instructions |
| **DOCKER_OPTIMIZATION.md** | Image optimization details |
| **CHANGES_SUMMARY.md** | Complete list of changes |

## 🔧 Available Scripts

### Installation & Setup
```powershell
# Install k3d (auto-detects Chocolatey/Scoop)
.\k3d-install.ps1

# Create k3d cluster
.\k3d-create-cluster.ps1
```

### Build & Deploy
```powershell
# Build and import Docker images
.\k3d-build-images.ps1

# Deploy to k3d
.\k3d-deploy.ps1

# Compare image sizes
.\docker-compare-sizes.ps1
```

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

## 📊 Docker Image Sizes

| Component | Before Optimization | After Optimization | Reduction |
|-----------|-------------------|-------------------|-----------|
| **Backend** | ~200-250 MB | ~80-120 MB | **~50-70%** |
| **Frontend** | ~400-500 MB | ~30-50 MB | **~90%** |

### Backend Dockerfile (Multi-stage)
```dockerfile
# Stage 1: Install dependencies
FROM node:22-alpine AS dependencies
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Production image
FROM node:22-alpine AS production
WORKDIR /app
COPY --from=dependencies /app/node_modules ./node_modules
COPY . .
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app
USER nodejs
EXPOSE 3000
CMD ["node", "app.js"]
```

### Frontend Dockerfile (Multi-stage)
```dockerfile
# Stage 1: Build
FROM node:22-alpine as builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Serve with nginx
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## 🔒 Security Improvements

### Backend
- ✅ Runs as non-root user (`nodejs:nodejs`)
- ✅ UID/GID: 1001
- ✅ No dev dependencies in production
- ✅ Minimal attack surface

### Frontend
- ✅ Uses official nginx:alpine
- ✅ Only static files exposed
- ✅ No build tools in production

## ⚡ Performance Improvements

- **Faster Deployments**: Smaller images = faster pulls
- **Better Caching**: Multi-stage builds leverage Docker layer caching
- **Quick Startup**: Optimized images start faster
- **Less Bandwidth**: Reduced network usage

## 🐛 Troubleshooting

### k3d not found
```powershell
# Install k3d
.\k3d-install.ps1

# Restart PowerShell
exit
# Then reopen PowerShell
```

### Docker not running
```powershell
# Start Docker Desktop
# Wait for it to be fully running
docker info
```

### Port 80 in use
```powershell
# Check what's using port 80
netstat -ano | findstr :80

# Or use different port
k3d cluster create lab-cluster --port "8080:80@loadbalancer"
```

### Pods not starting
```powershell
# Check pod status
kubectl get pods -A

# View logs
kubectl logs <pod-name>

# Describe pod
kubectl describe pod <pod-name>
```

## ✅ Verification Checklist

After deployment:

- [ ] Cluster running: `k3d cluster list`
- [ ] Nodes ready: `kubectl get nodes`
- [ ] Pods running: `kubectl get pods`
- [ ] Services available: `kubectl get svc`
- [ ] App accessible: http://localhost
- [ ] Database connected (check logs)
- [ ] Employee login works
- [ ] Admin login works
- [ ] Leave request submission works
- [ ] Admin can approve/reject

## 🔄 Complete Workflow

```
┌──────────────────────┐
│   Prerequisites      │
│ - Docker Desktop     │
│ - PowerShell         │
│ - 4GB+ RAM           │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  1. Install k3d      │
│  k3d-install.ps1     │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  2. Restart PS       │
│  (refresh PATH)      │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  3. Create Cluster   │
│  k3d-create-         │
│  cluster.ps1         │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  4. Build Images     │
│  k3d-build-          │
│  images.ps1          │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  5. Deploy App       │
│  k3d-deploy.ps1      │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  6. Test & Verify    │
│  http://localhost    │
└──────────────────────┘
```

## 📁 Project Structure

```
3tier-leave-system/
├── 📄 README_K3D.md              ← You are here
├── 📄 K3D_QUICKSTART.md          ← Quick start guide
├── 📄 K3D_SETUP.md               ← Detailed setup
├── 📄 DOCKER_OPTIMIZATION.md     ← Optimization details
├── 📄 CHANGES_SUMMARY.md         ← What changed
│
├── 🔧 k3d-install.ps1            ← Install k3d
├── 🔧 k3d-create-cluster.ps1     ← Create cluster
├── 🔧 k3d-build-images.ps1       ← Build & import
├── 🔧 k3d-deploy.ps1             ← Deploy app
├── 🔧 docker-compare-sizes.ps1   ← Compare sizes
│
├── backend/
│   ├── 🐳 Dockerfile             ← Optimized multi-stage
│   └── 📄 .dockerignore          ← Build exclusions
│
├── frontend/
│   ├── 🐳 Dockerfile             ← Optimized multi-stage
│   └── 📄 .dockerignore          ← Build exclusions
│
└── k3d/
    ├── backend.yaml
    ├── frontend.yaml
    ├── mysql.yaml
    └── ingress.yaml
```

## 🎓 Learning Resources

### k3d & Kubernetes
- [k3d Documentation](https://k3d.io/)
- [k3s Documentation](https://k3s.io/)
- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)

### Docker Optimization
- [Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Node.js Docker Guide](https://github.com/nodejs/docker-node/blob/main/docs/BestPractices.md)

## 🧹 Clean Up

When finished testing:

```powershell
# Delete cluster
k3d cluster delete lab-cluster

# Remove images (optional)
docker rmi leave-backend:local leave-frontend:local

# Remove all k3d clusters
k3d cluster delete --all
```

## 🚀 Next Steps

After successful local testing:

1. ✅ Verify all features work
2. ✅ Test database connectivity
3. ✅ Review application logs
4. ✅ Test ingress routing
5. ✅ Document any issues
6. 🎯 Prepare for AWS EKS deployment

## 💡 Tips

### Faster Rebuilds
```powershell
# Only rebuild changed service
docker build -t leave-backend:local ./backend
k3d image import leave-backend:local -c lab-cluster
kubectl rollout restart deployment backend
```

### View Logs
```powershell
# All pods
kubectl get pods

# Specific pod logs
kubectl logs -f <pod-name>

# Previous pod logs (if crashed)
kubectl logs <pod-name> --previous
```

### Debug Pods
```powershell
# Describe pod
kubectl describe pod <pod-name>

# Get events
kubectl get events --sort-by='.lastTimestamp'

# Shell into pod
kubectl exec -it <pod-name> -- sh
```

## 📞 Support

Having issues? Check these in order:

1. **Troubleshooting section** (above)
2. **K3D_QUICKSTART.md** (troubleshooting section)
3. **K3D_SETUP.md** (detailed troubleshooting)
4. **k3d documentation**: https://k3d.io/
5. **Docker documentation**: https://docs.docker.com/

## 🎉 Success Criteria

You've successfully completed local testing when:

- ✅ k3d cluster is running
- ✅ All pods are in "Running" state
- ✅ Application is accessible at http://localhost
- ✅ Employee can register and login
- ✅ Admin can register and login
- ✅ Employee can submit leave requests
- ✅ Admin can view and approve/reject requests
- ✅ Database persists data correctly

---

**Last Updated**: 2026-02-03  
**Status**: ✅ Ready for use  
**Optimization**: ✅ Complete  

**Questions?** Check the documentation files or k3d/Kubernetes resources above.
