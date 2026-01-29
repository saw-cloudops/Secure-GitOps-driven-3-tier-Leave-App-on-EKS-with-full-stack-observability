# Monitoring Guide: OTel, Prometheus, Grafana, Loki (S3)

This configuration enables full observability for the 3-Tier Leave System.

## 1. Stack Components
*   **Metrics**: OpenTelemetry (Node.js SDK) -> Exposes `/metrics` on port 9464.
*   **Collection**: Prometheus (via `kube-prometheus-stack`).
*   **Visualization**: Grafana.
*   **Logs**: Promtail (Collector) -> Loki (Storage in S3) -> Grafana.
*   **Alerts**: Alertmanager -> Email & MS Teams.

## 2. Installation (Helm)

### A. Install Prometheus & Grafana
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack (includes Prom, Graf, Alertmanager)
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  -f monitoring/values-prometheus.yaml
```

### B. Install Loki (Logs)
**Important**: Update `monitoring/values-loki.yaml` with your S3 Bucket details first!

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install loki grafana/loki-stack \
  --namespace monitoring \
  -f monitoring/values-loki.yaml
```

### C. Install Grafana Tempo (Tracing)
```bash
helm install tempo grafana/tempo \
  --namespace monitoring \
  --set receiver.otlp.protocols.http.endpoint="0.0.0.0:4318"
```

## 3. Apply Service Monitors
This tells Prometheus to scrape your Backend.

```bash
kubectl apply -f monitoring/service-monitors.yaml
```

## 4. Updates for Tracing
Your backend is configured to send Traces via OTLP.
Add this Environment Variable to `k8s/backend.yaml`:
- Name: `OTEL_EXPORTER_OTLP_ENDPOINT`
  Value: `http://tempo.monitoring.svc.cluster.local:4318`

## 5. Grafana Dashboards

**Access Grafana**:
```bash
kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80
```
User: `admin` | Password: (get from secret `prometheus-grafana`)

### Recommended Queries

**A. Backend Errors (Rate)**
```promql
sum(rate(http_request_duration_seconds_count{status_code=~"5.."}[5m]))
```

**B. Request Latency (P95)**
```promql
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m]) by (le)))
```

**C. Logs (Loki)**
Select Datasource: **Loki**
Query:
```logql
{app="backend"} |= "error"
```

## 5. Instrumenting Frontend
Currently, `nginx.conf` exposes `/metrics` with `stub_status`. 
To get this into Prometheus, deploying `nginx-prometheus-exporter` sidecar is recommended, but the Backend metrics (Request Duration, Status Codes) usually provide sufficient visibility into API health.


## 6. Verification & Endpoints (Debugging)

### A. Exposed Endpoints
These are the internal endpoints your applications are exposing for the monitoring tools.

| Component | Port | Path | Purpose | Consumed By |
| :--- | :--- | :--- | :--- | :--- |
| **Backend** | `9464` | `/metrics` | Application Metrics (Response times, internal Node.js stats) | Prometheus |
| **Frontend** | `80` | `/metrics` | Nginx Status (Active connections) | Prometheus |
| **Tempo** | `4318` | `/v1/traces` | OTLP Receiver (HTTP) for Traces | Backend App (Push) |

### B. Prometheus Verification Queries
Run these queries in Grafana (Explore > Prometheus) to verify your stack is fully operational.

**1. Check Scrape Status (Are monitors up?)**
This is the most important check. It should return `1`. If empty or `0`, Prometheus cannot reach your pod.
```promql
# Check Backend
up{job="backend-monitor"} 

# Check Frontend
up{job="frontend-monitor"}
```

**2. Verify OTel Metrics are flowing**
Confirm that the Node.js backend is actually producing data.
```promql
# Request count per minute
rate(http_request_duration_seconds_count[1m])
```

**3. Check Trace Generation**
Although traces live in Tempo, you can check if the span processor is working via metrics (if enabled) or simply check for HTTP requests that *should* be traced.
```promql
# High latency requests (candidates for tracing)
http_request_duration_seconds_bucket{le="+Inf"}
```

### C. How to Navigate
1.  **Logs**: Grafana > Explore > Datasource: `Loki` > `{app="backend"}`
2.  **Traces**: Grafana > Explore > Datasource: `Tempo` > Query Type: `Search` > Service Name: `leave-backend`
3.  **Metrics**: Grafana > Explore > Datasource: `Prometheus` > `up`


## 7. Advanced Hardening (Recommended)

### A. Alert Rules
We created `monitoring/alert-rules.yaml` which defines **High Error Rate** and **High Latency** alerts.
```bash
kubectl apply -f monitoring/alert-rules.yaml
```

### B. Network Security
To prevent unauthorized access to your Database from other pods (or hackers inside constraints), apply the Network Policy:
```bash
kubectl apply -f k8s/network-policies.yaml
```
*Note: This strictly limits MySQL traffic to ONLY come from pods labeled `app: backend`.*


