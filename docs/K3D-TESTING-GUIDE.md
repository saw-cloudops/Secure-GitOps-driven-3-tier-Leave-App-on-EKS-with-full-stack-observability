# k3d Local Kubernetes Testing Guide

## Overview

This guide helps you test your Leave Management System in a local Kubernetes environment using **k3d** before deploying to AWS EKS. This ensures your Kubernetes configurations work correctly without incurring AWS costs.

## What is k3d?

**k3d** is a lightweight wrapper to run **k3s** (Rancher Lab's minimal Kubernetes distribution) in Docker. It's perfect for:
- Local Kubernetes testing
- CI/CD pipelines
- Learning Kubernetes
- Testing before EKS deployment

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      k3d Local Cluster                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Your Browser (http://localhost)                                │
│         │                                                        │
│         ▼                                                        │
│  k3d Load Balancer (Port 80)                                    │
│         │                                                        │
│         ▼                                                        │
│  Traefik Ingress Controller (built-in)                          │
│         │                                                        │
│         ├─► /      ──► Frontend Pods (2 replicas)               │
│         │              └─► Nginx (leave-frontend:local)         │
│         │                                                        │
│         └─► /api/* ──► Backend Pods (2 replicas)                │
│                        └─► Node.js (leave-backend:local)        │
│                               │                                  │
│                               ▼                                  │
│                        MySQL Pod (1 replica)                    │
│                        └─► MySQL 8.0                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Prerequisites

- **Docker Desktop** installed and running
- **kubectl** installed
- **PowerShell** (Windows)
- At least **4GB RAM** available for Docker

## Quick Start

### Step 1: Setup k3d Cluster

```powershell
.\k3d-setup.ps1
```

This will:
- Install k3d (if not already installed)
- Create a cluster named `lab-cluster` with:
  - 1 server node (control plane)
  - 3 agent nodes (workers)
  - Port mappings: 80, 443, 8080

**Expected Output:**
```
✓ k3d installed successfully
✓ Cluster created successfully
```

### Step 2: Build and Import Docker Images

```powershell
.\k3d-build-images.ps1
```

This will:
- Build backend Docker image: `leave-backend:local`
- Build frontend Docker image: `leave-frontend:local`
- Import both images into k3d cluster

**Expected Output:**
```
✓ Backend image built successfully
✓ Frontend image built successfully
✓ Backend image imported successfully
✓ Frontend image imported successfully
```

### Step 3: Deploy Application

```powershell
.\k3d-deploy.ps1
```

This will deploy:
1. Namespace: `leave-system`
2. Secrets: Database credentials, JWT secret
3. MySQL: Database with initialization script
4. Backend: 2 replicas with health probes
5. Frontend: 2 replicas with health probes
6. Ingress: Traefik routing rules

**Expected Output:**
```
✓ Secrets created
✓ MySQL deployed
✓ MySQL is ready
✓ Backend deployed
✓ Backend is ready
✓ Frontend deployed
✓ Frontend is ready
✓ Ingress deployed
```

### Step 4: Test Deployment

```powershell
.\k3d-test.ps1
```

This will test:
- Backend health endpoint
- Frontend accessibility
- User registration API

**Expected Output:**
```
✓ Status: 200
✓ Response: OK
✓ Frontend is accessible
✓ User registered successfully
```

### Step 5: Access Application

Open your browser and navigate to:
- **Frontend**: http://localhost
- **Backend Health**: http://localhost/api/health

## Manual Testing

### Check Pod Status

```powershell
kubectl get pods -n leave-system
```

Expected output:
```
NAME                        READY   STATUS    RESTARTS   AGE
backend-xxxxx-xxxxx         1/1     Running   0          2m
backend-xxxxx-xxxxx         1/1     Running   0          2m
frontend-xxxxx-xxxxx        1/1     Running   0          2m
frontend-xxxxx-xxxxx        1/1     Running   0          2m
mysql-xxxxx-xxxxx           1/1     Running   0          3m
```

### Check Services

```powershell
kubectl get svc -n leave-system
```

Expected output:
```
NAME       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
backend    ClusterIP   10.43.xxx.xxx   <none>        3000/TCP,9464/TCP   2m
frontend   ClusterIP   10.43.xxx.xxx   <none>        80/TCP              2m
mysql      ClusterIP   10.43.xxx.xxx   <none>        3306/TCP            3m
```

### Check Ingress

```powershell
kubectl get ingress -n leave-system
```

Expected output:
```
NAME            CLASS    HOSTS   ADDRESS        PORTS   AGE
leave-ingress   <none>   *       172.18.0.2     80      2m
```

### View Logs

**Backend logs:**
```powershell
kubectl logs -l app=backend -n leave-system -f
```

**Frontend logs:**
```powershell
kubectl logs -l app=frontend -n leave-system -f
```

**MySQL logs:**
```powershell
kubectl logs -l app=mysql -n leave-system -f
```

### Test API Endpoints

**Health check:**
```powershell
curl http://localhost/api/health
```

**Register user:**
```powershell
$body = @{
    username = "testuser"
    password = "testpass123"
    role = "EMPLOYEE"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost/api/register" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"
```

**Login:**
```powershell
$body = @{
    username = "testuser"
    password = "testpass123"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost/api/login" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"
```

## Key Differences: k3d vs EKS

| Aspect | k3d (Local) | EKS (Production) |
|--------|-------------|------------------|
| **Ingress Controller** | Traefik (built-in) | AWS Load Balancer Controller |
| **Load Balancer** | k3d LB (localhost) | AWS ALB |
| **Image Registry** | Local Docker images | AWS ECR |
| **Image Pull Policy** | `Never` | `Always` |
| **Secrets** | Kubernetes Secrets (hardcoded) | External Secrets Operator + AWS Secrets Manager |
| **Database** | In-cluster MySQL pod | AWS RDS |
| **Storage** | emptyDir (ephemeral) | EBS volumes |
| **HTTPS** | Not configured | ACM certificate |
| **Cost** | Free | Pay per use |
| **Namespace** | `leave-system` | `default` (or custom) |

## File Structure

```
k3d/
├── secrets.yaml       # Kubernetes secrets with local values
├── mysql.yaml         # MySQL deployment with init script
├── backend.yaml       # Backend deployment (imagePullPolicy: Never)
├── frontend.yaml      # Frontend deployment (imagePullPolicy: Never)
└── ingress.yaml       # Traefik ingress rules

Scripts:
├── k3d-setup.ps1      # Install k3d and create cluster
├── k3d-build-images.ps1   # Build and import Docker images
├── k3d-deploy.ps1     # Deploy all resources
├── k3d-test.ps1       # Test deployment
└── k3d-cleanup.ps1    # Delete cluster and resources
```

## Configuration Details

### Secrets (k3d/secrets.yaml)

Local development values:
- `DB_HOST`: `mysql.leave-system.svc.cluster.local`
- `DB_USER`: `root`
- `DB_PASS`: `root`
- `DB_NAME`: `leave_db`
- `JWT_SECRET`: `k3d-local-secret-change-in-production`

### MySQL Initialization

The MySQL pod includes an init script that:
- Creates `users` table
- Creates `leave_requests` table
- Inserts default admin user (username: `admin`, password: `admin123`)

### Resource Limits

**Backend:**
- Requests: 100m CPU, 128Mi RAM
- Limits: 500m CPU, 512Mi RAM

**Frontend:**
- Requests: 50m CPU, 64Mi RAM
- Limits: 200m CPU, 256Mi RAM

**MySQL:**
- Requests: 250m CPU, 512Mi RAM
- Limits: 500m CPU, 1Gi RAM

## Troubleshooting

### Issue: Cluster creation fails

**Error:** `Failed to create cluster`

**Solution:**
```powershell
# Check Docker is running
docker ps

# Delete existing cluster
k3d cluster delete lab-cluster

# Try again
.\k3d-setup.ps1
```

### Issue: Pods stuck in "ImagePullBackOff"

**Error:** `Back-off pulling image "leave-backend:local"`

**Solution:**
```powershell
# Rebuild and reimport images
.\k3d-build-images.ps1

# Restart deployment
kubectl rollout restart deployment/backend -n leave-system
kubectl rollout restart deployment/frontend -n leave-system
```

### Issue: MySQL pod not ready

**Error:** `MySQL is not ready`

**Solution:**
```powershell
# Check MySQL logs
kubectl logs -l app=mysql -n leave-system

# Common issues:
# - Insufficient memory (increase Docker memory limit)
# - Initialization taking too long (wait 2-3 minutes)

# Restart MySQL
kubectl delete pod -l app=mysql -n leave-system
```

### Issue: Backend can't connect to database

**Error:** `Database connection failed`

**Solution:**
```powershell
# Check MySQL is running
kubectl get pods -l app=mysql -n leave-system

# Check secrets exist
kubectl get secret db-secrets -n leave-system

# Verify DB_HOST value
kubectl get secret db-secrets -n leave-system -o jsonpath='{.data.db-host}' | base64 -d

# Should output: mysql.leave-system.svc.cluster.local
```

### Issue: Can't access http://localhost

**Error:** `Connection refused`

**Solution:**
```powershell
# Check ingress is created
kubectl get ingress -n leave-system

# Check Traefik is running
kubectl get pods -n kube-system -l app.kubernetes.io/name=traefik

# Verify port mapping
k3d cluster list

# Should show: 0.0.0.0:80->80/tcp
```

### Issue: API calls return 404

**Error:** `404 Not Found for /api/health`

**Solution:**
```powershell
# Check backend service exists
kubectl get svc backend -n leave-system

# Check ingress rules
kubectl describe ingress leave-ingress -n leave-system

# Test backend directly
kubectl port-forward svc/backend 3000:3000 -n leave-system
curl http://localhost:3000/health
```

## Cleanup

To delete everything:

```powershell
.\k3d-cleanup.ps1
```

This will:
1. Delete the `leave-system` namespace (all deployments)
2. Delete the k3d cluster `lab-cluster`

## Migrating to EKS

Once your k3d testing is successful, you can deploy to EKS with confidence. The main changes needed:

1. **Use EKS manifests** from `k8s/` folder instead of `k3d/`
2. **Push images to ECR** instead of using local images
3. **Update image references** in deployments
4. **Configure External Secrets Operator** for AWS Secrets Manager
5. **Install AWS Load Balancer Controller** for ALB ingress
6. **Update ingress annotations** for ALB instead of Traefik

See `docs/DEPLOYMENT-CHECKLIST.md` for full EKS deployment guide.

## Benefits of k3d Testing

✅ **Fast iteration** - Test Kubernetes configs locally  
✅ **No AWS costs** - Free local testing  
✅ **Catch issues early** - Find problems before EKS deployment  
✅ **Learn Kubernetes** - Safe environment to experiment  
✅ **CI/CD integration** - Can be used in automated testing  
✅ **Identical behavior** - Same Kubernetes APIs as EKS  

## Next Steps

1. ✅ Test application in k3d
2. ✅ Verify all features work (register, login, leave requests)
3. ✅ Check logs for errors
4. ✅ Test with multiple users
5. ✅ Verify ingress routing
6. 🚀 Deploy to EKS with confidence!

## Additional Resources

- **k3d Documentation**: https://k3d.io/
- **k3s Documentation**: https://k3s.io/
- **Traefik Documentation**: https://doc.traefik.io/traefik/
- **kubectl Cheat Sheet**: https://kubernetes.io/docs/reference/kubectl/cheatsheet/

## Summary

k3d provides a **production-like Kubernetes environment** on your local machine, allowing you to:
- Test your Kubernetes manifests
- Verify ingress routing
- Debug issues locally
- Iterate quickly without AWS costs

Once everything works in k3d, you can confidently deploy to EKS knowing your configurations are correct!
