# 3-Tier Leave Management System

A modern, cloud-native leave management system built with a 3-tier architecture, designed for deployment on Kubernetes (k3d locally, AWS EKS in production).

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Presentation Layer                       │
│  React Frontend (Vite) - Modern UI with Tailwind CSS           │
└─────────────────────────────────────────────────────────────────┘
                              ↓ HTTP/HTTPS
┌─────────────────────────────────────────────────────────────────┐
│                         Application Layer                        │
│  Node.js Backend (Express) - REST API with JWT Auth            │
│  OpenTelemetry - Metrics, Traces, Logs                         │
└─────────────────────────────────────────────────────────────────┘
                              ↓ MySQL Protocol
┌─────────────────────────────────────────────────────────────────┐
│                            Data Layer                            │
│  MySQL 8.0 - Relational Database                               │
└─────────────────────────────────────────────────────────────────┘
```

## ✨ Features

### For Employees
- 👤 User registration and authentication
- 📝 Submit leave requests with date range and reason
- 📊 View own leave request history
- 🔔 See request status (Pending, Approved, Rejected)

### For Administrators
- 🔐 Admin authentication
- 📋 View all leave requests from all employees
- ✅ Approve leave requests
- ❌ Reject leave requests
- 👥 User management

### Technical Features
- 🔒 JWT-based authentication
- 📊 Prometheus metrics (OpenTelemetry)
- 🔍 Distributed tracing (Tempo/Jaeger)
- 📝 Structured logging
- 🚀 Horizontal pod autoscaling
- 🔄 Health checks and readiness probes
- 🌐 Ingress routing (Traefik/ALB)
- 🔐 Secrets management (Kubernetes/AWS Secrets Manager)

## 📁 Project Structure

```
3tier-leave-system/
├── frontend/                 # React frontend application
│   ├── src/
│   │   ├── components/      # React components
│   │   ├── pages/           # Page components
│   │   └── api.js           # API configuration
│   ├── public/
│   │   └── config.js        # Runtime configuration
│   ├── Dockerfile           # Multi-stage build
│   ├── nginx.conf           # Nginx configuration
│   └── entrypoint.sh        # Runtime config injection
│
├── backend/                  # Node.js backend API
│   ├── app.js               # Express application
│   ├── db.js                # Database connection
│   ├── auth.js              # JWT authentication
│   ├── instrumentation.js   # OpenTelemetry setup
│   ├── .env                 # Local environment variables
│   └── Dockerfile           # Backend container image
│
├── k3d/                      # Local Kubernetes testing
│   ├── secrets.yaml         # Local secrets
│   ├── mysql.yaml           # MySQL deployment
│   ├── backend.yaml         # Backend deployment
│   ├── frontend.yaml        # Frontend deployment
│   ├── ingress.yaml         # Traefik ingress
│   └── README.md            # k3d setup guide
│
├── k8s/                      # EKS production configs
│   ├── secrets.yaml         # Kubernetes secrets
│   ├── eso-store.yaml       # External Secrets Operator
│   ├── eso-secret.yaml      # AWS Secrets Manager ref
│   ├── mysql.yaml           # MySQL deployment
│   ├── backend.yaml         # Backend deployment
│   ├── backend-hpa.yaml     # Horizontal Pod Autoscaler
│   ├── frontend.yaml        # Frontend deployment
│   ├── ingress.yaml         # ALB ingress
│   └── network-policies.yaml # Network policies
│
├── monitoring/               # Observability stack
│   ├── values-prometheus.yaml
│   ├── values-loki.yaml
│   ├── service-monitors.yaml
│   └── alert-rules.yaml
│
├── terraform/                # Infrastructure as Code
│   ├── eks/                 # EKS cluster
│   ├── rds/                 # RDS database
│   └── networking/          # VPC, subnets, etc.
│
├── docs/                     # Documentation
│   ├── K3D-TESTING-GUIDE.md
│   ├── K3D-QUICK-REFERENCE.md
│   ├── API-CONFIGURATION.md
│   └── DEPLOYMENT-CHECKLIST.md
│
├── k3d-setup.ps1            # k3d cluster setup
├── k3d-build-images.ps1     # Build Docker images
├── k3d-deploy.ps1           # Deploy to k3d
├── k3d-test.ps1             # Test k3d deployment
├── k3d-cleanup.ps1          # Cleanup k3d
└── test-local-api.ps1       # Test local API
```

## 🚀 Quick Start

### Option 1: Local Development (Docker Compose)

```powershell
# Start database
docker-compose up -d

# Start backend
cd backend
npm install
node app.js

# Start frontend
cd frontend
npm install
npm run dev
```

Access: http://localhost:5173

### Option 2: Local Kubernetes (k3d)

```powershell
# 1. Setup k3d cluster
.\k3d-setup.ps1

# 2. Build and import images
.\k3d-build-images.ps1

# 3. Deploy application
.\k3d-deploy.ps1

# 4. Test deployment
.\k3d-test.ps1
```

Access: http://localhost

See [k3d/README.md](k3d/README.md) for detailed instructions.

### Option 3: AWS EKS Production

See [docs/DEPLOYMENT-CHECKLIST.md](docs/DEPLOYMENT-CHECKLIST.md)

## 🧪 Testing

### Local API Testing

```powershell
.\test-local-api.ps1
```

### k3d Testing

```powershell
.\k3d-test.ps1
```

### Manual Testing

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

## 📊 API Endpoints

### Public Endpoints
- `GET /health` - Health check
- `GET /api/health` - API health check
- `POST /api/register` - User registration
- `POST /api/login` - User login

### Employee Endpoints (Requires JWT)
- `POST /api/leave` - Submit leave request
- `GET /api/leave` - View own leave requests

### Admin Endpoints (Requires Admin JWT)
- `GET /api/admin/leaves` - View all leave requests
- `POST /api/admin/leave/:id` - Approve/reject leave request

## 🔧 Configuration

### Environment Variables

**Backend:**
- `DB_HOST` - Database host
- `DB_USER` - Database username
- `DB_PASS` - Database password
- `DB_NAME` - Database name
- `JWT_SECRET` - JWT signing secret
- `OTEL_EXPORTER_OTLP_ENDPOINT` - OpenTelemetry endpoint

**Frontend:**
- `API_URL` - Backend API URL

### Local vs k3d vs EKS

| Environment | Frontend URL | Backend API | Database |
|-------------|--------------|-------------|----------|
| **Local** | http://localhost:5173 | http://localhost:3000 | localhost:3306 |
| **k3d** | http://localhost | http://localhost/api | In-cluster MySQL |
| **EKS** | https://your-alb.com | https://your-alb.com/api | AWS RDS |

## 📚 Documentation

- **[K3D Testing Guide](docs/K3D-TESTING-GUIDE.md)** - Complete k3d setup and testing guide
- **[K3D Quick Reference](docs/K3D-QUICK-REFERENCE.md)** - Command cheat sheet
- **[API Configuration](docs/API-CONFIGURATION.md)** - API configuration across environments
- **[Deployment Checklist](docs/DEPLOYMENT-CHECKLIST.md)** - EKS deployment guide

## 🛠️ Technology Stack

### Frontend
- React 18
- Vite
- Tailwind CSS
- Axios

### Backend
- Node.js 22 LTS
- Express.js
- MySQL2
- JWT (jsonwebtoken)
- bcryptjs
- OpenTelemetry

### Infrastructure
- Kubernetes (k3d/EKS)
- Docker
- Traefik (k3d) / AWS ALB (EKS)
- MySQL 8.0 / AWS RDS
- Prometheus + Grafana
- Loki (Logging)
- Tempo (Tracing)

### DevOps
- Terraform (IaC)
- ArgoCD (GitOps)
- External Secrets Operator
- Karpenter (Node autoscaling)

## 🔐 Security Features

- ✅ JWT-based authentication
- ✅ Password hashing (bcrypt)
- ✅ Secrets management (Kubernetes Secrets / AWS Secrets Manager)
- ✅ Network policies
- ✅ HTTPS/TLS (EKS with ACM)
- ✅ Role-based access control (EMPLOYEE/ADMIN)

## 📈 Observability

### Metrics
- Prometheus metrics exposed at `:9464/metrics`
- Custom application metrics via OpenTelemetry
- Nginx metrics at `/metrics`

### Logging
- Structured JSON logs
- Exported to Loki
- Queryable via Grafana

### Tracing
- Distributed tracing via OpenTelemetry
- Exported to Tempo
- Visualized in Grafana

## 🔄 CI/CD

- GitHub Actions for CI
- ArgoCD for CD
- Automated image builds
- Automated deployments to EKS

## 🐛 Troubleshooting

### Local Development

```powershell
# Check backend is running
curl http://localhost:3000/health

# Check database connection
docker ps | grep mysql

# View backend logs
cd backend && node app.js
```

### k3d

```powershell
# Check pods
kubectl get pods -n leave-system

# View logs
kubectl logs -l app=backend -n leave-system

# Check ingress
kubectl get ingress -n leave-system
```

See [docs/K3D-TESTING-GUIDE.md](docs/K3D-TESTING-GUIDE.md) for detailed troubleshooting.

## 📝 Database Schema

### Users Table
```sql
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('EMPLOYEE', 'ADMIN') DEFAULT 'EMPLOYEE',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Leave Requests Table
```sql
CREATE TABLE leave_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  reason TEXT,
  status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

## 🎯 Roadmap

- [x] Basic CRUD operations
- [x] JWT authentication
- [x] Role-based access control
- [x] OpenTelemetry integration
- [x] k3d local testing
- [x] EKS deployment
- [ ] Email notifications
- [ ] Leave balance tracking
- [ ] Calendar integration
- [ ] Mobile app

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally with k3d
5. Submit a pull request

## 📄 License

MIT License - See LICENSE file for details

## 👥 Authors

- Your Name - Initial work

## 🙏 Acknowledgments

- OpenTelemetry community
- Kubernetes community
- k3d maintainers

---

**Ready to get started?**

1. **Local Development**: Start with `docker-compose up -d`
2. **Kubernetes Testing**: Try k3d with `.\k3d-setup.ps1`
3. **Production**: Deploy to EKS following the deployment checklist

See the [documentation](docs/) for detailed guides!
