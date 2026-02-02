# API Configuration: Local vs EKS

## Summary

**✅ NO CODE CHANGES NEEDED!** Your application is already configured to work in both environments.

## How It Works

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         LOCAL ENVIRONMENT                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Browser                                                         │
│    │                                                             │
│    ├─► http://localhost:5173  ──► Frontend (Vite Dev Server)    │
│    │                                │                            │
│    └─► http://localhost:3000/api/* ──► Backend (Node.js)        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                          EKS ENVIRONMENT                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Browser                                                         │
│    │                                                             │
│    └─► https://your-alb.elb.amazonaws.com                       │
│              │                                                   │
│              ▼                                                   │
│        AWS ALB (Ingress)                                         │
│              │                                                   │
│              ├─► /      ──► Frontend Service (Nginx)            │
│              │                                                   │
│              └─► /api/* ──► Backend Service (Node.js)           │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Configuration Comparison

### 1. Frontend API URL

**File: `frontend/src/api.js`**
```javascript
export const API_URL = window.env?.API_URL || "/api";
```

| Environment | API_URL Value | Set By | API Calls Go To |
|-------------|---------------|--------|-----------------|
| **Local** | `http://localhost:3000` | `public/config.js` | Direct to backend server |
| **EKS** | `/api` (default) | Environment variable in pod | Relative path → Ingress routes to backend |

**How it works:**
- **Local**: Frontend at `localhost:5173` calls `http://localhost:3000/api/login`
- **EKS**: Frontend at `https://your-alb.com` calls `https://your-alb.com/api/login` → Ingress routes to backend pod

### 2. Backend Environment Variables

**File: `backend/.env` (Local) vs `k8s/backend.yaml` (EKS)**

| Variable | Local | EKS | Source in EKS |
|----------|-------|-----|---------------|
| `DB_HOST` | `localhost` | `mysql.default.svc.cluster.local` | Kubernetes Secret (ESO) |
| `DB_USER` | `root` | From AWS Secrets Manager | Kubernetes Secret (ESO) |
| `DB_PASS` | `root` | From AWS Secrets Manager | Kubernetes Secret (ESO) |
| `DB_NAME` | `leave_db` | From AWS Secrets Manager | Kubernetes Secret (ESO) |
| `JWT_SECRET` | `local-secret` | From AWS Secrets Manager | Kubernetes Secret (ESO) |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | (not set) | `http://tempo.monitoring.svc.cluster.local:4318` | Hardcoded in deployment |

### 3. CORS Configuration

**File: `backend/app.js`**
```javascript
app.use((req, res, next) => {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Headers", "*");
  next();
});
```

✅ **Works for both environments** - Allows all origins

### 4. Health Check Endpoints

**Available at:**
- `GET /health` - Root level health check (for ALB)
- `GET /api/health` - API level health check

Both return `"OK"` and are used by:
- **Local**: Manual testing
- **EKS**: ALB health checks (configured in `ingress.yaml`)

## Testing Your Setup

### Local Testing

1. **Start MySQL:**
   ```bash
   docker-compose up -d
   ```

2. **Start Backend:**
   ```bash
   cd backend
   npm install
   node app.js
   ```
   Expected output: `Backend running on 3000`

3. **Start Frontend:**
   ```bash
   cd frontend
   npm install
   npm run dev
   ```
   Expected output: `Local: http://localhost:5173/`

4. **Run Test Script:**
   ```powershell
   .\test-local-api.ps1
   ```

5. **Manual Test:**
   - Open browser: `http://localhost:5173`
   - Register a user
   - Check browser DevTools → Network tab
   - Verify API calls go to: `http://localhost:3000/api/*`

### EKS Testing

1. **Deploy to EKS:**
   ```bash
   kubectl apply -f k8s/
   ```

2. **Get ALB URL:**
   ```bash
   kubectl get ingress leave-ingress
   ```

3. **Test Health Endpoint:**
   ```bash
   curl https://your-alb-url/api/health
   ```
   Expected: `OK`

4. **Test in Browser:**
   - Open: `https://your-alb-url/`
   - Register a user
   - Check browser DevTools → Network tab
   - Verify API calls go to: `https://your-alb-url/api/*`

## Key Files

### Frontend Configuration
- **`frontend/src/api.js`** - API URL configuration
- **`frontend/public/config.js`** - Local development API URL
- **`frontend/entrypoint.sh`** - Generates config.js in container from env vars
- **`k8s/frontend.yaml`** - Sets `API_URL=/api` environment variable

### Backend Configuration
- **`backend/.env`** - Local environment variables
- **`backend/db.js`** - Database connection (uses env vars)
- **`k8s/backend.yaml`** - EKS deployment with secret references
- **`k8s/eso-secret.yaml`** - External Secrets Operator config

### Routing Configuration
- **`k8s/ingress.yaml`** - ALB Ingress routing rules
  - `/` → Frontend Service
  - `/api` → Backend Service

## Common Issues & Solutions

### Issue: "Cannot connect to backend"

**Local:**
- ✓ Check backend is running: `node backend/app.js`
- ✓ Check `frontend/public/config.js` has correct URL
- ✓ Check MySQL is running: `docker ps`

**EKS:**
- ✓ Check pods are running: `kubectl get pods`
- ✓ Check ingress is created: `kubectl get ingress`
- ✓ Check backend logs: `kubectl logs -l app=backend`

### Issue: "CORS error"

**Both:**
- ✓ Backend has CORS headers (already configured)
- ✓ In EKS, use same domain for frontend and backend (Ingress handles this)

### Issue: "Database connection failed"

**Local:**
- ✓ Check `.env` file exists in `backend/`
- ✓ Check MySQL is running and accessible

**EKS:**
- ✓ Check secrets exist: `kubectl get secret db-secrets`
- ✓ Check ESO is syncing: `kubectl get externalsecret`
- ✓ Check RDS endpoint is correct in AWS Secrets Manager

## Summary

Your application uses a **smart configuration pattern** that works seamlessly in both environments:

1. **Frontend** uses dynamic API URL configuration
2. **Backend** uses environment variables for all config
3. **Ingress** provides unified routing in EKS
4. **No code changes** needed when deploying to EKS!

The only difference is **where the configuration values come from**:
- Local: `.env` files and `config.js`
- EKS: Kubernetes Secrets and environment variables
