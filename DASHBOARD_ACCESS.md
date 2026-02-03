# 📊 Central Monitoring Dashboard

Your 3-Tier Leave System is now fully instrumented!

## 1. Access Grafana
Grafana is the single pane of glass for Metrics, Logs, and Traces.

### Get Password
```powershell
$PASS = kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | % { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
Write-Host "Password: $PASS"
```

### Connect
```powershell
kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80
```
Open **[http://localhost:3000](http://localhost:3000)** (User: `admin`)

---

## 2. Configure Data Sources (Manual Step)
Since we reset the stack, you need to add these one-time connections:

### A. Add Loki (Logs) 🪵
1.  **Connections** -> **Data sources** -> **Add new**.
2.  Select **Loki**.
3.  URL: `http://loki:3100` (Access: Server/Default)
4.  **Save & test**.

### B. Add Tempo (Traces) 🔎
1.  **Connections** -> **Data sources** -> **Add new**.
2.  Select **Tempo**.
3.  URL: `http://tempo.monitoring.svc.cluster.local:3200`
4.  **Save & test**.

---

## 3. Verify Your Data

### Metrics (Prometheus) 📈
*   **Where**: Explore -> Prometheus
*   **Query**: `up{job="backend-monitor"}` (Should be `1`)

### Logs (Loki) 📜
*   **Where**: Explore -> Loki
*   **Query**: `{app="backend"}`

### Traces (Tempo) ⚡
*   **Where**: Explore -> Tempo -> Search
*   **Service**: `leave-backend`
*   **Action**: Run Query (after generating traffic on the app)

---

## 4. Status Check
If anything looks broken, check the pods:
```powershell
kubectl get pods -n monitoring
```
*   `prometheus-operator`: Manages the stack.
*   `prometheus-...-0`: The database (might take a minute to initialize).
*   `loki-0`: Log storage.
*   `tempo-0`: Trace storage.
