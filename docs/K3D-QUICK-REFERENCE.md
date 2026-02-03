# k3d Quick Reference

## 🚀 Quick Start (4 Commands)

```powershell
# 1. Setup cluster
.\k3d-setup.ps1

# 2. Build images
.\k3d-build-images.ps1

# 3. Deploy app
.\k3d-deploy.ps1

# 4. Test app
.\k3d-test.ps1
```

**Access:** http://localhost

---

## 📋 Common Commands

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

### Pod Management
```powershell
# List pods
kubectl get pods -n leave-system

# Describe pod
kubectl describe pod <pod-name> -n leave-system

# View logs
kubectl logs <pod-name> -n leave-system -f

# Exec into pod
kubectl exec -it <pod-name> -n leave-system -- sh

# Restart deployment
kubectl rollout restart deployment/<name> -n leave-system
```

### Service & Ingress
```powershell
# List services
kubectl get svc -n leave-system

# List ingress
kubectl get ingress -n leave-system

# Describe ingress
kubectl describe ingress leave-ingress -n leave-system
```

### Debugging
```powershell
# Port forward to backend
kubectl port-forward svc/backend 3000:3000 -n leave-system

# Port forward to frontend
kubectl port-forward svc/frontend 8080:80 -n leave-system

# Port forward to MySQL
kubectl port-forward svc/mysql 3306:3306 -n leave-system

# Get all resources
kubectl get all -n leave-system

# Check events
kubectl get events -n leave-system --sort-by='.lastTimestamp'
```

### Image Management
```powershell
# Rebuild backend
docker build -t leave-backend:local ./backend
k3d image import leave-backend:local -c lab-cluster

# Rebuild frontend
docker build -t leave-frontend:local ./frontend
k3d image import leave-frontend:local -c lab-cluster

# Rebuild both
.\k3d-build-images.ps1
```

---

## 🧪 Testing Endpoints

```powershell
# Health check
curl http://localhost/api/health

# Frontend
curl http://localhost/

# Register user
$body = @{ username = "test"; password = "pass123"; role = "EMPLOYEE" } | ConvertTo-Json
Invoke-WebRequest -Uri "http://localhost/api/register" -Method POST -Body $body -ContentType "application/json"

# Login
$body = @{ username = "test"; password = "pass123" } | ConvertTo-Json
Invoke-WebRequest -Uri "http://localhost/api/login" -Method POST -Body $body -ContentType "application/json"
```

---

## 🔍 Troubleshooting

### Pods not starting?
```powershell
kubectl describe pod <pod-name> -n leave-system
kubectl logs <pod-name> -n leave-system
```

### Can't access localhost?
```powershell
# Check ingress
kubectl get ingress -n leave-system

# Check Traefik
kubectl get pods -n kube-system -l app.kubernetes.io/name=traefik
```

### Database connection issues?
```powershell
# Check MySQL pod
kubectl get pods -l app=mysql -n leave-system

# Check secrets
kubectl get secret db-secrets -n leave-system -o yaml

# Test connection
kubectl exec -it <backend-pod> -n leave-system -- sh
# Inside pod:
# apk add mysql-client
# mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME
```

### Image pull errors?
```powershell
# Reimport images
.\k3d-build-images.ps1

# Restart pods
kubectl delete pod -l app=backend -n leave-system
kubectl delete pod -l app=frontend -n leave-system
```

---

## 🗑️ Cleanup

```powershell
# Delete namespace only
kubectl delete namespace leave-system

# Delete entire cluster
k3d cluster delete lab-cluster

# Or use script
.\k3d-cleanup.ps1
```

---

## 📊 Resource Status

```powershell
# Quick overview
kubectl get all -n leave-system

# Detailed status
kubectl get pods,svc,ingress -n leave-system -o wide

# Watch pods
kubectl get pods -n leave-system -w

# Resource usage
kubectl top pods -n leave-system
kubectl top nodes
```

---

## 🔄 Update Workflow

After code changes:

```powershell
# 1. Rebuild images
.\k3d-build-images.ps1

# 2. Restart deployments
kubectl rollout restart deployment/backend -n leave-system
kubectl rollout restart deployment/frontend -n leave-system

# 3. Watch rollout
kubectl rollout status deployment/backend -n leave-system
kubectl rollout status deployment/frontend -n leave-system

# 4. Test
.\k3d-test.ps1
```

---

## 📁 File Locations

| File | Purpose |
|------|---------|
| `k3d/secrets.yaml` | Local secrets |
| `k3d/mysql.yaml` | MySQL deployment |
| `k3d/backend.yaml` | Backend deployment |
| `k3d/frontend.yaml` | Frontend deployment |
| `k3d/ingress.yaml` | Traefik ingress |

---

## 🎯 Key Differences: k3d vs EKS

| Feature | k3d | EKS |
|---------|-----|-----|
| **Access** | http://localhost | https://your-alb.com |
| **Ingress** | Traefik | ALB |
| **Images** | Local Docker | ECR |
| **Secrets** | K8s Secrets | ESO + AWS SM |
| **Database** | In-cluster | RDS |
| **Cost** | Free | $$$ |

---

## ✅ Success Checklist

- [ ] All pods in `Running` state
- [ ] `curl http://localhost/api/health` returns `OK`
- [ ] Frontend loads at http://localhost
- [ ] Can register new user
- [ ] Can login as employee
- [ ] Can login as admin
- [ ] No errors in pod logs

---

## 🆘 Need Help?

1. Check pod logs: `kubectl logs <pod> -n leave-system`
2. Check events: `kubectl get events -n leave-system`
3. Describe resource: `kubectl describe <resource> -n leave-system`
4. See full guide: `docs/K3D-TESTING-GUIDE.md`

---

## 🚀 Ready for EKS?

Once k3d testing passes:
1. Push images to ECR
2. Update `k8s/` manifests with ECR image URLs
3. Deploy to EKS: `kubectl apply -f k8s/`
4. See: `docs/DEPLOYMENT-CHECKLIST.md`
