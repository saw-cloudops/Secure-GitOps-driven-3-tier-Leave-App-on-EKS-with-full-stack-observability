# k3d Local Testing - Complete Setup

## Overview

This directory contains all the configurations needed to run your Leave Management System in a **local Kubernetes cluster using k3d**. This allows you to test your Kubernetes deployments before migrating to AWS EKS.

## 🎯 Why k3d?

- ✅ Test Kubernetes configs locally (no AWS costs)
- ✅ Identical to EKS behavior (same Kubernetes APIs)
- ✅ Fast iteration and debugging
- ✅ Catch issues before production deployment
- ✅ Learn and experiment safely

## 📁 Directory Structure

```
k3d/
├── secrets.yaml       # Kubernetes secrets (local dev values)
├── mysql.yaml         # MySQL database deployment + init script
├── backend.yaml       # Backend API deployment (2 replicas)
├── frontend.yaml      # Frontend web deployment (2 replicas)
└── ingress.yaml       # Traefik ingress routing rules
```

## 🚀 Quick Start

### Prerequisites

- Docker Desktop running
- kubectl installed
- PowerShell

### Step 1: Setup k3d Cluster

```powershell
.\k3d-setup.ps1
```

Creates a cluster with 1 server + 3 agents, with ports 80, 443, 8080 exposed.

### Step 2: Build Docker Images

```powershell
.\k3d-build-images.ps1
```

Builds `leave-backend:local` and `leave-frontend:local` and imports them into k3d.

### Step 3: Deploy Application

```powershell
.\k3d-deploy.ps1
```

Deploys MySQL, Backend, Frontend, and Ingress to the `leave-system` namespace.

### Step 4: Test

```powershell
.\k3d-test.ps1
```

Runs automated tests against the deployed application.

### Step 5: Access Application

Open your browser: **http://localhost**

## 📊 What Gets Deployed

| Component | Replicas | Image | Ports |
|-----------|----------|-------|-------|
| **MySQL** | 1 | mysql:8.0 | 3306 |
| **Backend** | 2 | leave-backend:local | 3000, 9464 |
| **Frontend** | 2 | leave-frontend:local | 80 |
| **Ingress** | - | Traefik (built-in) | 80, 443 |

## 🔧 Configuration Details

### Secrets (Local Values)

```yaml
DB_HOST: mysql.leave-system.svc.cluster.local
DB_USER: root
DB_PASS: root
DB_NAME: leave_db
JWT_SECRET: k3d-local-secret-change-in-production
```

### Ingress Routing

- `http://localhost/` → Frontend Service
- `http://localhost/api/*` → Backend Service

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

## 🧪 Testing

### Automated Tests

```powershell
.\k3d-test.ps1
```

Tests:
- Backend health endpoint
- Frontend accessibility
- User registration API

### Manual Tests

```powershell
# Health check
curl http://localhost/api/health

# Register user
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

### Browser Testing

1. Open http://localhost
2. Register as Employee
3. Login and submit leave request
4. Register as Admin (or use default: admin/admin123)
5. Login as Admin and approve/reject requests

## 🔍 Monitoring & Debugging

### Check Pod Status

```powershell
kubectl get pods -n leave-system
```

Expected: All pods in `Running` state

### View Logs

```powershell
# Backend logs
kubectl logs -l app=backend -n leave-system -f

# Frontend logs
kubectl logs -l app=frontend -n leave-system -f

# MySQL logs
kubectl logs -l app=mysql -n leave-system -f
```

### Port Forwarding (Direct Access)

```powershell
# Access backend directly
kubectl port-forward svc/backend 3000:3000 -n leave-system
# Then: curl http://localhost:3000/health

# Access MySQL directly
kubectl port-forward svc/mysql 3306:3306 -n leave-system
# Then: mysql -h localhost -u root -proot leave_db
```

### Check Resources

```powershell
# All resources
kubectl get all -n leave-system

# Services
kubectl get svc -n leave-system

# Ingress
kubectl get ingress -n leave-system

# Events (for troubleshooting)
kubectl get events -n leave-system --sort-by='.lastTimestamp'
```

## 🔄 Update Workflow

After making code changes:

```powershell
# 1. Rebuild and reimport images
.\k3d-build-images.ps1

# 2. Restart deployments
kubectl rollout restart deployment/backend -n leave-system
kubectl rollout restart deployment/frontend -n leave-system

# 3. Watch rollout status
kubectl rollout status deployment/backend -n leave-system
kubectl rollout status deployment/frontend -n leave-system

# 4. Test changes
.\k3d-test.ps1
```

## 🐛 Troubleshooting

### Pods Not Starting

```powershell
# Check pod status
kubectl describe pod <pod-name> -n leave-system

# Check logs
kubectl logs <pod-name> -n leave-system
```

### Image Pull Errors

```powershell
# Rebuild and reimport
.\k3d-build-images.ps1

# Delete and recreate pods
kubectl delete pod -l app=backend -n leave-system
kubectl delete pod -l app=frontend -n leave-system
```

### Can't Access http://localhost

```powershell
# Check ingress
kubectl get ingress -n leave-system

# Check Traefik (k3d's ingress controller)
kubectl get pods -n kube-system -l app.kubernetes.io/name=traefik

# Verify cluster port mapping
k3d cluster list
```

### Database Connection Issues

```powershell
# Check MySQL is running
kubectl get pods -l app=mysql -n leave-system

# Check secrets
kubectl get secret db-secrets -n leave-system -o yaml

# Test from backend pod
kubectl exec -it <backend-pod> -n leave-system -- sh
# Inside pod: ping mysql.leave-system.svc.cluster.local
```

## 🗑️ Cleanup

### Delete Deployment Only

```powershell
kubectl delete namespace leave-system
```

### Delete Entire Cluster

```powershell
k3d cluster delete lab-cluster
```

### Or Use Cleanup Script

```powershell
.\k3d-cleanup.ps1
```

## 📚 Key Differences: k3d vs EKS

| Aspect | k3d (Local) | EKS (Production) |
|--------|-------------|------------------|
| **Ingress Controller** | Traefik (built-in) | AWS Load Balancer Controller |
| **Load Balancer** | k3d LB (localhost) | AWS ALB |
| **Image Source** | Local Docker | AWS ECR |
| **Image Pull Policy** | `Never` | `Always` |
| **Secrets Management** | Kubernetes Secrets | External Secrets Operator + AWS Secrets Manager |
| **Database** | In-cluster MySQL pod | AWS RDS MySQL |
| **Storage** | emptyDir (ephemeral) | EBS volumes (persistent) |
| **HTTPS/TLS** | Not configured | ACM certificate on ALB |
| **DNS** | localhost | Route53 + ALB DNS |
| **Namespace** | `leave-system` | `default` (or custom) |
| **Cost** | **FREE** | Pay per use |

## 🎯 Migration Path to EKS

Once k3d testing is successful:

### 1. Update Image References

Change from:
```yaml
image: leave-backend:local
imagePullPolicy: Never
```

To:
```yaml
image: <AWS_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/leave-backend:latest
imagePullPolicy: Always
```

### 2. Update Secrets

Replace `k3d/secrets.yaml` with:
- `k8s/eso-store.yaml` (External Secrets Operator config)
- `k8s/eso-secret.yaml` (AWS Secrets Manager reference)

### 3. Update Ingress

Replace `k3d/ingress.yaml` with `k8s/ingress.yaml`:
- Change from Traefik annotations to ALB annotations
- Add ACM certificate ARN
- Configure health checks

### 4. Deploy to EKS

```bash
# Push images to ECR
docker tag leave-backend:local <ECR_URL>/leave-backend:latest
docker push <ECR_URL>/leave-backend:latest

docker tag leave-frontend:local <ECR_URL>/leave-frontend:latest
docker push <ECR_URL>/leave-frontend:latest

# Deploy to EKS
kubectl apply -f k8s/
```

See `docs/DEPLOYMENT-CHECKLIST.md` for detailed EKS deployment steps.

## 📖 Documentation

- **[K3D Testing Guide](../docs/K3D-TESTING-GUIDE.md)** - Comprehensive guide with architecture and troubleshooting
- **[K3D Quick Reference](../docs/K3D-QUICK-REFERENCE.md)** - Command cheat sheet
- **[API Configuration](../docs/API-CONFIGURATION.md)** - How API calls work in k3d vs EKS
- **[Deployment Checklist](../docs/DEPLOYMENT-CHECKLIST.md)** - EKS deployment guide

## ✅ Success Criteria

Your k3d deployment is successful when:

- ✅ All pods are in `Running` state
- ✅ `curl http://localhost/api/health` returns `OK`
- ✅ Frontend loads at http://localhost
- ✅ Can register new users
- ✅ Can login as employee and admin
- ✅ Employee can submit leave requests
- ✅ Admin can approve/reject requests
- ✅ No errors in pod logs

## 🎓 Learning Resources

- **k3d Documentation**: https://k3d.io/
- **k3s Documentation**: https://k3s.io/
- **Traefik Documentation**: https://doc.traefik.io/traefik/
- **kubectl Cheat Sheet**: https://kubernetes.io/docs/reference/kubectl/cheatsheet/

## 💡 Tips

1. **Start Fresh**: If things get messy, run `.\k3d-cleanup.ps1` and start over
2. **Watch Logs**: Keep logs open while testing: `kubectl logs -l app=backend -n leave-system -f`
3. **Use Port Forwarding**: Debug services directly with `kubectl port-forward`
4. **Check Events**: Use `kubectl get events -n leave-system` to see what's happening
5. **Resource Limits**: Adjust in YAML files if pods are OOMKilled

## 🚀 Next Steps

1. ✅ Complete k3d testing
2. ✅ Verify all features work
3. ✅ Review logs for errors
4. ✅ Test edge cases
5. 🎯 Deploy to EKS with confidence!

## 📞 Support

If you encounter issues:

1. Check pod logs: `kubectl logs <pod> -n leave-system`
2. Check events: `kubectl get events -n leave-system`
3. Describe resource: `kubectl describe <resource> -n leave-system`
4. Review documentation in `docs/`
5. Try cleanup and redeploy: `.\k3d-cleanup.ps1` then start over

---

**Happy Testing! 🎉**

Once everything works in k3d, you're ready for EKS deployment!
