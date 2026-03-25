# 🏢 Cloud-Native Leave Management System

> A production-grade, fully containerized 3-tier Leave Management System deployed on **Amazon EKS** with a GitOps-driven CI/CD pipeline, full-stack observability, and enterprise-grade security practices.

---

## 📌 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Features](#-features)
- [Project Structure](#-project-structure)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Kubernetes & GitOps](#-kubernetes--gitops)
- [Observability Stack](#-observability-stack)
- [Security](#-security)
- [Database Schema](#-database-schema)
- [API Reference](#-api-reference)
- [Getting Started (Local)](#-getting-started-local)
- [Deployment Guide (EKS)](#-deployment-guide-eks)

---

## 🔍 Overview

This project is a **cloud-native, production-ready 3-Tier Leave Management System** that demonstrates real-world DevOps and Cloud Engineering practices. It allows employees to apply for leave and administrators to approve or reject requests through a clean, responsive UI.

The entire system — from code commit to live deployment — is automated through a **4-stage GitLab CI/CD pipeline** that implements the **GitOps** pattern using **ArgoCD**.

### Live Endpoints

| Service  | URL |
|---|---|
| Application | `https://leave.cloudstackmm.site` |
| Grafana Dashboard | `https://grafana.cloudstackmm.site` |

---

## 🏗 Architecture

```
┌──────────────────────────────────────────────────────────────────────────┐
│                           AWS Cloud (ap-southeast-1)                     │
│                                                                          │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                    Amazon EKS Cluster                             │   │
│  │                                                                   │   │
│  │   Internet ──► AWS ALB ──► Ingress Controller                    │   │
│  │                                  │                                │   │
│  │                    ┌─────────────┴──────────────┐                │   │
│  │                    ▼                            ▼                 │   │
│  │           ┌────────────────┐         ┌─────────────────┐         │   │
│  │           │  Frontend Pod  │         │  Grafana Ingress │         │   │
│  │           │  (React/Nginx) │         │  (Monitoring UI) │         │   │
│  │           └───────┬────────┘         └─────────────────┘         │   │
│  │                   │ /api/*                                        │   │
│  │                   ▼                                               │   │
│  │           ┌────────────────┐   Metrics :9464                     │   │
│  │           │ Backend Pods   │──────────────────► Prometheus        │   │
│  │           │ (Node.js x2)   │   Traces (OTLP)──► Tempo            │   │
│  │           │     HPA ↕      │   Logs ──────────► Loki             │   │
│  │           └───────┬────────┘                                      │   │
│  │                   │ NetworkPolicy: allow only backend              │   │
│  │                   ▼                                               │   │
│  │           ┌────────────────┐                                      │   │
│  │           │  MySQL Pod     │ (PVC: 1Gi gp2)                      │   │
│  │           └────────────────┘                                      │   │
│  │                                                                   │   │
│  │   ┌────────────────────────────────────────────────────────┐     │   │
│  │   │  Monitoring Namespace                                   │     │   │
│  │   │  Prometheus · Grafana · Loki · Tempo · Alertmanager    │     │   │
│  │   └────────────────────────────────────────────────────────┘     │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                          │
│   AWS Secrets Manager ──► External Secrets Operator ──► K8s Secrets     │
│   AWS ACM (TLS/HTTPS)                                                   │
└──────────────────────────────────────────────────────────────────────────┘

GitLab Repo ──► CI/CD Pipeline ──► GitOps (ArgoCD) ──► EKS Cluster
```

---

## 🛠 Tech Stack

### Application
| Layer | Technology |
|---|---|
| **Frontend** | React 18, Vite, Tailwind CSS, Nginx |
| **Backend** | Node.js 22, Express.js, JWT Auth, bcryptjs |
| **Database** | MySQL 8 |

### Infrastructure & DevOps
| Category | Technology |
|---|---|
| **Container Runtime** | Docker (multi-stage builds) |
| **Orchestration** | Amazon EKS (Kubernetes) |
| **CI/CD** | GitLab CI/CD |
| **GitOps** | ArgoCD (auto-sync + self-heal) |
| **Ingress** | AWS Load Balancer Controller (ALB) |
| **TLS/HTTPS** | AWS Certificate Manager (ACM) |
| **Secret Management** | AWS Secrets Manager + External Secrets Operator |

### Observability
| Tool | Purpose |
|---|---|
| **Prometheus** | Metrics collection & alerting |
| **Grafana** | Dashboards & visualization |
| **Loki** | Log aggregation (S3-backed) |
| **Grafana Tempo** | Distributed tracing (S3-backed) |
| **OpenTelemetry SDK** | Auto-instrumentation for metrics & traces |

### Security & Testing
| Tool | Purpose |
|---|---|
| **GitLab SAST** | Static Application Security Testing |
| **GitLab Secret Detection** | Scan for hardcoded secrets |
| **GitLab Dependency Scanning** | Scan for vulnerable npm packages |
| **Jest + Supertest** | Backend unit & integration tests |
| **Vitest** | Frontend component tests |

---

## ✨ Features

### Employee Portal
- 🔐 **Secure Authentication** — JWT-based login with bcrypt password hashing
- 📝 **Apply for Leave** — Submit leave requests with start date, end date, and reason
- 📋 **View Leave History** — See all personal leave requests and their approval status

### Admin Dashboard
- 👥 **User Management** — View all employees and their leave requests
- ✅ **Approve / Reject** — One-click approve or reject any pending leave request
- 📊 **Full Visibility** — See all requests across the organization

### Platform Features
- ⚡ **Auto-Scaling** — Backend HPA scales from 2→5 pods on CPU >50% or Memory >70%
- 🔄 **Self-Healing** — ArgoCD automatically reconciles drifted Kubernetes state
- 🔒 **Network Isolation** — Kubernetes NetworkPolicies restrict MySQL access to backend only
- 🔑 **Secret Rotation** — AWS Secrets Manager secrets auto-synced to K8s every 1 hour via ESO

---

## 📁 Project Structure

```
3-tier-leave-management-system/
├── 📂 backend/                    # Node.js Express API server
│   ├── app.js                     # Main application, all API routes
│   ├── auth.js                    # JWT authentication middleware
│   ├── db.js                      # MySQL connection pool
│   ├── instrumentation.js         # OpenTelemetry SDK setup
│   ├── Dockerfile                 # Multi-stage production Dockerfile
│   └── tests/                     # Jest + Supertest test suite
│
├── 📂 frontend/                   # React + Vite SPA
│   ├── src/
│   │   ├── App.jsx                # Main app with routing & auth state
│   │   ├── components/            # Login, Register, Admin, Employee components
│   │   └── api.js                 # Axios API client
│   ├── nginx.conf                 # Nginx config with /api proxy pass
│   └── Dockerfile                 # Multi-stage: Vite build → Nginx serve
│
├── 📂 k8s/                        # Core Kubernetes manifests (GitOps source)
│   ├── backend.yaml               # Deployment + Service (2 replicas, port 3000 & 9464)
│   ├── frontend.yaml              # Deployment + Service (Nginx, port 80)
│   ├── mysql.yaml                 # Deployment + Service + PVC (1Gi gp2)
│   ├── backend-hpa.yaml           # HorizontalPodAutoscaler (min:2, max:5)
│   ├── ingress.yaml               # ALB Ingress (HTTPS, ACM, leave.cloudstackmm.site)
│   ├── grafana-ingress.yaml       # ALB Ingress (grafana.cloudstackmm.site)
│   └── secrets.yaml               # K8s Secret template (managed by ESO in prod)
│
├── 📂 k8s-additional/             # Additional production configs
│   ├── eso-store.yaml             # ClusterSecretStore → AWS Secrets Manager
│   ├── eso-secret.yaml            # ExternalSecret → maps AWS secrets to K8s secret
│   ├── ingress.yaml               # Alternative ingress (with stricter rules)
│   └── network-policies.yaml      # NetworkPolicy: MySQL only accessible by backend
│
├── 📂 argocd/                     # GitOps configuration
│   └── application.yaml           # ArgoCD Application (auto-prune + self-heal)
│
├── 📂 monitoring/                 # Observability stack Helm values
│   ├── values-prometheus.yaml     # kube-prometheus-stack (Prometheus + Grafana)
│   ├── alert-rules.yaml           # PrometheusRule: HighErrorRate, HighLatency, Down alerts
│   ├── service-monitors.yaml      # ServiceMonitor: scrape backend metrics at /metrics
│   ├── values-loki.yaml           # Loki (S3 backend + IRSA)
│   └── values-tempo.yaml          # Grafana Tempo (S3 backend + IRSA)
│
├── 📂 load-test/                  # k6 load testing scripts
├── .gitlab-ci.yml                 # 4-stage CI/CD pipeline definition
└── db.sql                         # Database initialization schema
```

---

## 🚀 CI/CD Pipeline

The pipeline is defined in `.gitlab-ci.yml` and runs automatically on every commit to the default branch. It implements a **4-stage GitOps workflow**:

```
┌──────────┐    ┌──────────┐    ┌─────────────┐    ┌──────────────┐
│  1. test  │───►│2.security│───►│  3. build   │───►│  4. deploy   │
└──────────┘    └──────────┘    └─────────────┘    └──────────────┘
   Backend          SAST          Docker build       Update k8s/
   & Frontend      Secret Det.    & push to          backend.yaml &
   unit tests      Dep. Scan      GitLab Registry    frontend.yaml
   with coverage                  (tagged by SHA)   → git push → ArgoCD
```

### Stage Details

| Stage | Job | Description |
|---|---|---|
| **test** | `test_backend` | `npm ci && npm test -- --coverage` in `/backend` |
| **test** | `test_frontend` | `npm ci && npm test -- --coverage` in `/frontend` |
| **security** | `sast` | GitLab SAST scan (semgrep, nodejs-scan) |
| **security** | `secret_detection` | Scan all commits for leaked credentials |
| **security** | `dependency_scanning` | Audit npm dependencies for CVEs |
| **build** | `build_and_push` | Multi-arch Docker build → GitLab Container Registry (tagged with `$CI_COMMIT_SHORT_SHA` + `latest`) |
| **deploy** | `update_manifests` | `sed` image tags in `k8s/backend.yaml` & `k8s/frontend.yaml` → commit & push → ArgoCD detects change |

---

## ☸️ Kubernetes & GitOps

### GitOps Flow

```
Developer pushes code
        │
        ▼
GitLab CI builds new Docker image
        │ tagged with git SHA (e.g. 6768dea9)
        ▼
CI pipeline updates k8s/backend.yaml & k8s/frontend.yaml
        │ with new image tag
        ▼
ArgoCD detects diff in Git repo (every 3 min or webhook)
        │
        ▼
ArgoCD syncs cluster state to match Git ← Single Source of Truth
        │ (auto-prune + self-heal enabled)
        ▼
New pods roll out with zero downtime
```

### ArgoCD Application (`argocd/application.yaml`)
```yaml
syncPolicy:
  automated:
    prune: true       # Remove resources deleted from Git
    selfHeal: true    # Revert manual kubectl changes
```

### Horizontal Pod Autoscaler
```
Backend scales: 2 pods (min) → 5 pods (max)
  ├── CPU > 50% utilization  → scale up
  └── Memory > 70% utilization → scale up
```

### Secret Management with External Secrets Operator
```
AWS Secrets Manager (prod/leave-system/db)
        │  refreshInterval: 1h
        ▼
ClusterSecretStore (aws-secrets-manager)
        │
        ▼
ExternalSecret → creates K8s Secret: "db-secrets"
        │
        ├── DB_HOST, DB_USER, DB_PASS, DB_NAME (injected into backend pods)
        └── JWT_SECRET (injected into backend pods)
```

---

## 📊 Observability Stack

The full observability stack is deployed into the `monitoring` namespace using Helm.

### Metrics Pipeline (Prometheus → Grafana)
```
Backend Pod (:9464/metrics)
    │ OpenTelemetry Prometheus Exporter
    ▼
ServiceMonitor (scrape every 15s)
    │
    ▼
Prometheus (2Gi PVC storage)
    │
    ▼
Grafana Dashboards (grafana.cloudstackmm.site)
    + kube-state-metrics (cluster health)
    + node-exporter (node-level metrics)
```

### Tracing Pipeline (OpenTelemetry → Tempo)
```
Backend Pod
    │ OTLP HTTP → http://tempo.monitoring.svc.cluster.local:4318
    ▼
Grafana Tempo (S3-backed, IRSA auth)
    │
    ▼
Grafana → Explore → Trace view (correlated with logs)
```

### Logging Pipeline (Promtail → Loki)
```
All K8s Pod stdout/stderr
    │ Promtail DaemonSet
    ▼
Grafana Loki (S3-backed, IRSA auth)
    │
    ▼
Grafana → Explore → LogQL queries
```

### Alert Rules (`monitoring/alert-rules.yaml`)

| Alert | Condition | Severity |
|---|---|---|
| `HighErrorRate` | >5% 5xx responses for 2 min | 🔴 Critical |
| `HighLatency` | P95 latency >1s for 5 min | 🟡 Warning |
| `BackendDown` | Prometheus cannot scrape backend for 1 min | 🔴 Critical |

---

## 🔒 Security

This project implements **Defense-in-Depth** across multiple layers:

| Layer | Implementation |
|---|---|
| **Transport** | HTTPS enforced via ACM certificate + ALB SSL redirect |
| **Authentication** | JWT Bearer tokens, bcrypt password hashing (cost factor 10) |
| **Authorization** | Role-based access control (`EMPLOYEE` / `ADMIN`) enforced in middleware |
| **Secret Management** | No secrets in code; all injected via AWS Secrets Manager + ESO |
| **Network** | K8s NetworkPolicy: MySQL only reachable from backend pods |
| **Container** | Non-root user (`nodejs` uid 1001), `dumb-init` for proper signal handling |
| **Image** | Multi-stage build minimizes attack surface; no dev dependencies in prod image |
| **CI/CD** | SAST + Secret Detection + Dependency Scanning on every commit |

---

## 🗄 Database Schema

```sql
-- Users table
CREATE TABLE users (
  id       INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE,
  password VARCHAR(255),          -- bcrypt hashed
  role     ENUM('EMPLOYEE','ADMIN') DEFAULT 'EMPLOYEE'
);

-- Leave Requests table
CREATE TABLE leave_requests (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  user_id    INT,
  start_date DATE,
  end_date   DATE,
  reason     VARCHAR(255),
  status     ENUM('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 📡 API Reference

All routes prefixed with `/api`. Protected routes require `Authorization: Bearer <token>`.

| Method | Endpoint | Auth | Description |
|---|---|---|---|
| `GET` | `/api/health` | None | Health check → `{"status":"healthy"}` |
| `POST` | `/api/register` | None | Register user `{username, password, role}` |
| `POST` | `/api/login` | None | Login → returns `{token, role}` |
| `POST` | `/api/leave` | Employee | Submit leave `{start_date, end_date, reason}` |
| `GET` | `/api/leave` | Employee | Get own leave requests |
| `GET` | `/api/admin/leaves` | Admin | Get ALL leave requests with usernames |
| `POST` | `/api/admin/leave/:id` | Admin | Approve/Reject leave `{status}` |

---

## 💻 Getting Started (Local)

### Prerequisites
- Docker & Docker Compose
- Node.js 22+, MySQL 8

### 1. Clone the repo
```bash
git clone https://gitlab.com/sawcloudops30/3_tier_leave_management_app.git
cd 3-tier-leave-management-system
```

### 2. Run the backend
```bash
cd backend
export DB_HOST=localhost
export DB_USER=root
export DB_PASS=yourpassword
export DB_NAME=leave_db
export JWT_SECRET=yoursecretkey
npm ci
npm start
# API available at http://localhost:3000
```

### 3. Run the frontend
```bash
cd frontend
npm ci
npm run dev
# UI available at http://localhost:5173
```

### 4. Initialize database
```bash
mysql -u root -p leave_db < db.sql
```

### 5. Run tests
```bash
# Backend tests with coverage
cd backend && npm test -- --coverage

# Frontend tests
cd frontend && npm test -- --coverage
```

---

## ☁️ Deployment Guide (EKS)

### Prerequisites
- AWS CLI configured, `kubectl` connected to your EKS cluster
- ArgoCD installed in `argocd` namespace
- AWS Load Balancer Controller installed
- External Secrets Operator installed

### Step 1: Store secrets in AWS Secrets Manager
```bash
aws secretsmanager create-secret \
  --name prod/leave-system/db \
  --secret-string '{"username":"admin","password":"...","host":"your-rds-endpoint","dbname":"leave_db","jwt_secret":"..."}'
```

### Step 2: Deploy the monitoring stack
```bash
# Add Helm repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# kube-prometheus-stack (Prometheus + Grafana + Alertmanager)
helm install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f monitoring/values-prometheus.yaml

# Loki (log aggregation, S3-backed)
helm install loki grafana/loki \
  -n monitoring \
  -f monitoring/values-loki.yaml

# Grafana Tempo (distributed tracing, S3-backed)
helm install tempo grafana/tempo \
  -n monitoring \
  -f monitoring/values-tempo.yaml

# Apply ServiceMonitors and Alert Rules
kubectl apply -f monitoring/service-monitors.yaml
kubectl apply -f monitoring/alert-rules.yaml
```

### Step 3: Apply ESO secret store & external secret
```bash
kubectl apply -f k8s-additional/eso-store.yaml
kubectl apply -f k8s-additional/eso-secret.yaml
# This creates the k8s secret "db-secrets" pulled from AWS Secrets Manager
```

### Step 4: Register ArgoCD Application
```bash
# Edit argocd/application.yaml with your repo URL, then:
kubectl apply -f argocd/application.yaml
# ArgoCD will auto-sync k8s/ manifests to your cluster
```

### Step 5: Apply network policies & ingress
```bash
kubectl apply -f k8s-additional/network-policies.yaml
kubectl apply -f k8s/ingress.yaml
kubectl apply -f k8s/grafana-ingress.yaml
```

### Step 6: Push code — pipeline takes over
```bash
git push origin main
# GitLab CI runs: test → security → build → update manifests
# ArgoCD detects manifest change → deploys new image automatically
```

---

## 📈 Key DevOps Concepts Demonstrated

| Concept | Implementation |
|---|---|
| **3-Tier Architecture** | Separate Frontend, Backend, Database layers |
| **GitOps** | ArgoCD as single source of truth from Git |
| **CI/CD** | 4-stage automated pipeline (test → security → build → deploy) |
| **Infrastructure as Code** | All K8s resources declared as YAML manifests |
| **Secret Management** | AWS Secrets Manager + External Secrets Operator |
| **Observability (Three Pillars)** | Metrics (Prometheus), Logs (Loki), Traces (Tempo) |
| **Auto-Scaling** | HPA based on CPU & Memory metrics |
| **Security-First** | SAST, Dependency Scanning, NetworkPolicies, non-root containers |
| **High Availability** | Multi-replica deployments, self-healing via ArgoCD |
| **Cloud-Native** | Fully containerized, 12-factor app principles |

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m "feat: add your feature"`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Merge Request

---

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).

---

<div align="center">

**Built with ❤️ using AWS EKS · GitLab CI · ArgoCD · OpenTelemetry · Grafana**

*Demonstrating production-grade DevOps practices*

</div>