# Local to EKS Deployment Checklist

## ✅ Pre-Deployment Verification

### Local Testing
- [ ] Backend starts successfully: `cd backend && node app.js`
- [ ] Frontend starts successfully: `cd frontend && npm run dev`
- [ ] MySQL/Database is running and accessible
- [ ] Can register a user via frontend
- [ ] Can login as employee
- [ ] Can login as admin
- [ ] API calls visible in browser DevTools go to `http://localhost:3000/api/*`
- [ ] Run test script: `.\test-local-api.ps1` - all tests pass

### Code Review
- [ ] `frontend/src/api.js` uses: `window.env?.API_URL || "/api"`
- [ ] `frontend/public/config.js` has: `API_URL: "http://localhost:3000"`
- [ ] `backend/.env` has all required variables (DB_HOST, DB_USER, etc.)
- [ ] `backend/app.js` has CORS headers configured
- [ ] Health endpoints exist: `/health` and `/api/health`

## 🚀 EKS Deployment Checklist

### AWS Prerequisites
- [ ] EKS cluster is running (v1.32)
- [ ] AWS Load Balancer Controller is installed
- [ ] External Secrets Operator is installed
- [ ] Secrets exist in AWS Secrets Manager: `prod/leave-system/db`
- [ ] RDS MySQL instance is running and accessible from EKS
- [ ] ECR repositories created:
  - [ ] `leave-backend`
  - [ ] `leave-frontend`

### Kubernetes Configuration
- [ ] `k8s/frontend.yaml` has `API_URL=/api` environment variable ✅ (Just added!)
- [ ] `k8s/backend.yaml` references correct secrets
- [ ] `k8s/ingress.yaml` has correct ACM certificate ARN
- [ ] `k8s/eso-secret.yaml` references correct AWS Secrets Manager path
- [ ] `k8s/eso-store.yaml` has correct AWS region and service account

### Docker Images
- [ ] Backend Docker image built and pushed to ECR
- [ ] Frontend Docker image built and pushed to ECR
- [ ] Image tags updated in deployment YAML files

### Deployment Steps
1. [ ] Apply secrets configuration:
   ```bash
   kubectl apply -f k8s/eso-store.yaml
   kubectl apply -f k8s/eso-secret.yaml
   ```

2. [ ] Verify secrets are synced:
   ```bash
   kubectl get externalsecret
   kubectl get secret db-secrets
   ```

3. [ ] Deploy MySQL (if using in-cluster):
   ```bash
   kubectl apply -f k8s/mysql.yaml
   ```

4. [ ] Deploy backend:
   ```bash
   kubectl apply -f k8s/backend.yaml
   ```

5. [ ] Deploy frontend:
   ```bash
   kubectl apply -f k8s/frontend.yaml
   ```

6. [ ] Deploy ingress:
   ```bash
   kubectl apply -f k8s/ingress.yaml
   ```

7. [ ] Wait for ALB to be provisioned:
   ```bash
   kubectl get ingress leave-ingress -w
   ```

### Post-Deployment Verification

#### Check Pods
```bash
kubectl get pods
```
Expected:
- [ ] `backend-xxx` - Running
- [ ] `frontend-xxx` - Running
- [ ] `mysql-xxx` - Running (if using in-cluster)

#### Check Services
```bash
kubectl get svc
```
Expected:
- [ ] `backend` - ClusterIP
- [ ] `frontend` - ClusterIP
- [ ] `mysql` - ClusterIP (if using in-cluster)

#### Check Ingress
```bash
kubectl get ingress leave-ingress
```
Expected:
- [ ] ADDRESS field shows ALB DNS name
- [ ] Copy the ALB URL

#### Test Endpoints
```bash
# Replace YOUR_ALB_URL with actual URL
curl https://YOUR_ALB_URL/api/health
```
Expected: `OK`

```bash
curl https://YOUR_ALB_URL/
```
Expected: HTML content (frontend)

#### Test in Browser
- [ ] Open `https://YOUR_ALB_URL/` in browser
- [ ] Frontend loads successfully
- [ ] Open DevTools → Network tab
- [ ] Register a new user
- [ ] Verify API calls go to: `https://YOUR_ALB_URL/api/*`
- [ ] Login as employee works
- [ ] Login as admin works
- [ ] Employee can submit leave request
- [ ] Admin can view/approve/reject leave requests

#### Check Logs
```bash
# Backend logs
kubectl logs -l app=backend --tail=50

# Frontend logs
kubectl logs -l app=frontend --tail=50
```

Look for:
- [ ] No error messages
- [ ] Backend: "Backend running on 3000"
- [ ] Backend: "Prometheus metrics ready at :9464/metrics"
- [ ] Database connections successful

## 🔍 Troubleshooting

### Pods not starting
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Secrets not syncing
```bash
kubectl get externalsecret backend-secrets-eso -o yaml
kubectl describe externalsecret backend-secrets-eso
```

### Ingress not creating ALB
```bash
kubectl describe ingress leave-ingress
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

### API calls failing
1. Check backend pod logs
2. Verify secrets are correct
3. Test backend health: `kubectl port-forward svc/backend 3000:3000` then `curl localhost:3000/health`
4. Check database connectivity from backend pod

### Database connection issues
```bash
# Exec into backend pod
kubectl exec -it <backend-pod-name> -- sh

# Test database connection
apk add mysql-client
mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME
```

## 📊 Monitoring

### Check Metrics
```bash
# Backend metrics
kubectl port-forward svc/backend 9464:9464
curl localhost:9464/metrics

# Frontend metrics
kubectl port-forward svc/frontend 80:80
curl localhost:80/metrics
```

### Check Traces (if Tempo is deployed)
```bash
kubectl port-forward -n monitoring svc/grafana 3000:80
# Open http://localhost:3000 in browser
# Login and check Tempo data source
```

## ✨ Success Criteria

Your deployment is successful when:
- ✅ All pods are in `Running` state
- ✅ Ingress has an ALB address
- ✅ `curl https://YOUR_ALB_URL/api/health` returns `OK`
- ✅ Frontend loads in browser
- ✅ Can register and login users
- ✅ Employee can submit leave requests
- ✅ Admin can manage leave requests
- ✅ No errors in pod logs
- ✅ Metrics endpoints are accessible

## 🎯 Key Differences: Local vs EKS

| Aspect | Local | EKS |
|--------|-------|-----|
| **API URL** | `http://localhost:3000` | `/api` (relative) |
| **Frontend URL** | `http://localhost:5173` | `https://your-alb-url/` |
| **Backend URL** | `http://localhost:3000` | `https://your-alb-url/api` |
| **Database** | `localhost:3306` | RDS endpoint or `mysql.default.svc` |
| **Secrets** | `.env` file | Kubernetes Secrets (from AWS SM) |
| **Routing** | Direct calls | ALB Ingress routing |
| **HTTPS** | No | Yes (via ACM certificate) |

## 📝 Notes

- **No code changes needed** when moving from local to EKS!
- Configuration is handled via environment variables
- Ingress provides unified routing for frontend and backend
- Same domain eliminates CORS issues in EKS
