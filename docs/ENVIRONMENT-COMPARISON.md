# Environment Comparison: Local → k3d → EKS

## Visual Architecture Comparison

### 1️⃣ Local Development Environment

```
┌─────────────────────────────────────────────────────────────────┐
│                    Your Local Machine                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Browser (http://localhost:5173)                                │
│         │                                                        │
│         ├─► Frontend (Vite Dev Server)                          │
│         │   Port: 5173                                          │
│         │   Source: frontend/src                                │
│         │                                                        │
│         └─► Backend (Node.js)                                   │
│             Port: 3000                                           │
│             Source: backend/app.js                               │
│             Config: backend/.env                                 │
│                   │                                              │
│                   ▼                                              │
│             MySQL (Docker)                                       │
│             Port: 3306                                           │
│             Data: Docker volume                                  │
│                                                                  │
│  Characteristics:                                                │
│  ✓ Fast iteration                                               │
│  ✓ Hot reload                                                   │
│  ✓ Direct debugging                                             │
│  ✗ Not production-like                                          │
│  ✗ No Kubernetes                                                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 2️⃣ k3d Local Kubernetes Environment

```
┌─────────────────────────────────────────────────────────────────┐
│              k3d Cluster (Docker Containers)                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Browser (http://localhost)                                     │
│         │                                                        │
│         ▼                                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  k3d Load Balancer (Port 80 → Cluster)                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│         │                                                        │
│         ▼                                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Traefik Ingress Controller (Built-in)                   │  │
│  │  Routes:                                                  │  │
│  │    /      → frontend:80                                   │  │
│  │    /api/* → backend:3000                                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│         │                                                        │
│         ├─────────────────────┬─────────────────────────────┐  │
│         ▼                     ▼                             ▼  │
│  ┌─────────────┐      ┌─────────────┐              ┌─────────┐│
│  │ Frontend    │      │ Frontend    │              │ Backend ││
│  │ Pod 1       │      │ Pod 2       │              │ Pod 1   ││
│  │             │      │             │              │         ││
│  │ Nginx       │      │ Nginx       │              │ Node.js ││
│  │ Port: 80    │      │ Port: 80    │              │ Port:   ││
│  │             │      │             │              │ 3000    ││
│  │ Image:      │      │ Image:      │              │ 9464    ││
│  │ leave-      │      │ leave-      │              │         ││
│  │ frontend:   │      │ frontend:   │              │ Image:  ││
│  │ local       │      │ local       │              │ leave-  ││
│  └─────────────┘      └─────────────┘              │ backend:││
│                                                     │ local   ││
│                                                     └────┬────┘│
│                                                          │     │
│                       ┌──────────────────────────────────┘     │
│                       ▼                             ▼          │
│                ┌─────────────┐              ┌─────────┐       │
│                │ Backend     │              │ MySQL   │       │
│                │ Pod 2       │              │ Pod     │       │
│                │             │              │         │       │
│                │ Node.js     │──────────────│ MySQL   │       │
│                │ Port:       │              │ 8.0     │       │
│                │ 3000        │              │         │       │
│                │ 9464        │              │ Port:   │       │
│                │             │              │ 3306    │       │
│                │ Image:      │              │         │       │
│                │ leave-      │              │ Data:   │       │
│                │ backend:    │              │ emptyDir│       │
│                │ local       │              │         │       │
│                └─────────────┘              └─────────┘       │
│                                                                │
│  Characteristics:                                              │
│  ✓ Production-like (Kubernetes)                               │
│  ✓ Test ingress routing                                       │
│  ✓ Test pod scaling                                           │
│  ✓ Test health probes                                         │
│  ✓ Free (local)                                               │
│  ✗ Slower iteration                                           │
│  ✗ Data lost on restart (emptyDir)                            │
│                                                                │
└─────────────────────────────────────────────────────────────────┘
```

### 3️⃣ AWS EKS Production Environment

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Cloud                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Browser (https://your-domain.com)                              │
│         │                                                        │
│         ▼                                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Route 53 (DNS)                                           │  │
│  │  your-domain.com → ALB                                    │  │
│  └──────────────────────────────────────────────────────────┘  │
│         │                                                        │
│         ▼                                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Application Load Balancer (ALB)                          │  │
│  │  - ACM Certificate (HTTPS)                                │  │
│  │  - Health checks                                          │  │
│  │  - SSL termination                                        │  │
│  │  Routes:                                                  │  │
│  │    /      → frontend:80                                   │  │
│  │    /api/* → backend:3000                                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│         │                                                        │
│         ▼                                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  EKS Cluster (Managed Kubernetes)                         │  │
│  │                                                            │  │
│  │  ┌────────────────────────────────────────────────────┐  │  │
│  │  │  Namespace: default                                 │  │  │
│  │  │                                                      │  │  │
│  │  │  Frontend Pods (HPA: 2-10)                          │  │  │
│  │  │  ┌─────────┐  ┌─────────┐  ┌─────────┐            │  │  │
│  │  │  │Frontend │  │Frontend │  │Frontend │            │  │  │
│  │  │  │Pod 1    │  │Pod 2    │  │Pod N    │            │  │  │
│  │  │  │         │  │         │  │         │            │  │  │
│  │  │  │Nginx    │  │Nginx    │  │Nginx    │            │  │  │
│  │  │  │         │  │         │  │         │            │  │  │
│  │  │  │Image:   │  │Image:   │  │Image:   │            │  │  │
│  │  │  │ECR/     │  │ECR/     │  │ECR/     │            │  │  │
│  │  │  │frontend │  │frontend │  │frontend │            │  │  │
│  │  │  └─────────┘  └─────────┘  └─────────┘            │  │  │
│  │  │                                                      │  │  │
│  │  │  Backend Pods (HPA: 2-10)                           │  │  │
│  │  │  ┌─────────┐  ┌─────────┐  ┌─────────┐            │  │  │
│  │  │  │Backend  │  │Backend  │  │Backend  │            │  │  │
│  │  │  │Pod 1    │  │Pod 2    │  │Pod N    │            │  │  │
│  │  │  │         │  │         │  │         │            │  │  │
│  │  │  │Node.js  │  │Node.js  │  │Node.js  │            │  │  │
│  │  │  │         │  │         │  │         │            │  │  │
│  │  │  │Image:   │  │Image:   │  │Image:   │            │  │  │
│  │  │  │ECR/     │  │ECR/     │  │ECR/     │            │  │  │
│  │  │  │backend  │  │backend  │  │backend  │            │  │  │
│  │  │  └────┬────┘  └────┬────┘  └────┬────┘            │  │  │
│  │  │       │            │            │                  │  │  │
│  │  │       └────────────┴────────────┘                  │  │  │
│  │  │                    │                               │  │  │
│  │  └────────────────────┼───────────────────────────────┘  │  │
│  │                       │                                  │  │
│  └───────────────────────┼──────────────────────────────────┘  │
│                          │                                     │
│                          ▼                                     │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  AWS RDS MySQL (Multi-AZ)                                │  │
│  │  - Automated backups                                     │  │
│  │  - High availability                                     │  │
│  │  - Automatic failover                                    │  │
│  │  - Persistent storage (EBS)                              │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  AWS Secrets Manager                                      │  │
│  │  - DB credentials                                         │  │
│  │  - JWT secret                                             │  │
│  │  - Synced via External Secrets Operator                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Monitoring Stack (Optional)                              │  │
│  │  - Prometheus (Metrics)                                   │  │
│  │  - Loki (Logs)                                            │  │
│  │  - Tempo (Traces)                                         │  │
│  │  - Grafana (Visualization)                                │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  Characteristics:                                               │
│  ✓ Production-ready                                            │
│  ✓ High availability                                           │
│  ✓ Auto-scaling                                                │
│  ✓ Managed services                                            │
│  ✓ Persistent data                                             │
│  ✓ HTTPS/TLS                                                   │
│  ✗ Costs money                                                 │
│  ✗ Complex setup                                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Configuration Comparison Table

| Component | Local | k3d | EKS |
|-----------|-------|-----|-----|
| **Access URL** | http://localhost:5173 | http://localhost | https://your-domain.com |
| **Frontend** | Vite dev server | Nginx in pod | Nginx in pod |
| **Backend** | Direct Node.js | Node.js in pod | Node.js in pod |
| **Database** | Docker MySQL | MySQL pod | AWS RDS |
| **Load Balancer** | None | k3d LB | AWS ALB |
| **Ingress** | None | Traefik | ALB Ingress Controller |
| **TLS/HTTPS** | No | No | Yes (ACM) |
| **Secrets** | .env file | K8s Secrets | ESO + AWS SM |
| **Images** | Local source | Local Docker | AWS ECR |
| **Image Pull** | N/A | Never | Always |
| **Storage** | Local disk | emptyDir | EBS volumes |
| **Scaling** | Manual | HPA | HPA + Karpenter |
| **Monitoring** | None | Optional | Prometheus/Grafana |
| **Cost** | Free | Free | $$$ |
| **Setup Time** | 5 minutes | 10 minutes | 1-2 hours |
| **Data Persistence** | Yes | No (ephemeral) | Yes (RDS) |

## API Call Flow Comparison

### Local Development
```
Browser
  └─► http://localhost:5173 (Frontend - Vite)
        └─► http://localhost:3000/api/* (Backend - Direct)
              └─► localhost:3306 (MySQL - Docker)
```

### k3d
```
Browser
  └─► http://localhost (k3d LB)
        └─► Traefik Ingress
              ├─► /      → frontend:80 (Nginx pods)
              │             └─► Serves static files
              │
              └─► /api/* → backend:3000 (Node.js pods)
                            └─► mysql.leave-system.svc:3306 (MySQL pod)
```

### EKS
```
Browser
  └─► https://your-domain.com (Route 53)
        └─► AWS ALB (HTTPS termination)
              ├─► /      → frontend:80 (Nginx pods)
              │             └─► Serves static files
              │
              └─► /api/* → backend:3000 (Node.js pods)
                            └─► RDS endpoint:3306 (AWS RDS)
```

## When to Use Each Environment

### Use Local Development When:
- 🔧 Developing new features
- 🐛 Debugging application logic
- 🚀 Need fast iteration
- 📝 Writing/testing code changes

### Use k3d When:
- ✅ Testing Kubernetes configurations
- 🔍 Verifying ingress routing
- 📊 Testing pod scaling
- 🧪 Pre-deployment validation
- 📚 Learning Kubernetes

### Use EKS When:
- 🚀 Production deployment
- 👥 Serving real users
- 📈 Need high availability
- 💾 Need persistent data
- 🔒 Need enterprise security

## Migration Path

```
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│   Local Dev  │ ───► │     k3d      │ ───► │     EKS      │
│              │      │              │      │              │
│ Fast coding  │      │ Test K8s     │      │ Production   │
│ Hot reload   │      │ configs      │      │ deployment   │
│ Direct debug │      │ Validate     │      │ Real users   │
│              │      │ routing      │      │              │
└──────────────┘      └──────────────┘      └──────────────┘
     ↓                      ↓                      ↓
  5 minutes            10 minutes              1-2 hours
     ↓                      ↓                      ↓
    Free                  Free                   $$$
```

## Summary

1. **Start with Local** - Fast development and debugging
2. **Test with k3d** - Validate Kubernetes configs work
3. **Deploy to EKS** - Production-ready with confidence

Each environment serves a specific purpose in your development workflow!
