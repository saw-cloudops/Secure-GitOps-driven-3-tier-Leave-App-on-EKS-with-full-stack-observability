# ✅ Monitoring Stack Verification

We have successfully installed **Prometheus**, **Grafana**, and **Tempo** (Trace Monitor).

## 1. Access Grafana

Grafana is the central dashboard for both Metrics (Prometheus) and Traces (Tempo).

### Get Admin Password
Run this command in PowerShell to retrieve the password:
```powershell
$PASS = kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}"; [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($PASS))
```

### Enable Access
Forward the Grafana port to your local machine:
```powershell
kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80
```
*(Keep this terminal open)*

**URL:** [http://localhost:3000](http://localhost:3000)
**User:** `admin`
**Password:** *(Output from command above)*

## 2. Configure Trace Monitor (Tempo)

Since you are using OpenTelemetry traces, **Grafana Tempo** is your trace backend. It is compatible with your current setup because your backend exports via OTLP/HTTP to Tempo.

**Action Required:** Connect Grafana to Tempo.

1.  Log in to Grafana.
2.  Go to **Connections** -> **Data sources** -> **Add new data source**.
3.  Search for **Tempo**.
4.  **URL**: `http://tempo.monitoring.svc.cluster.local:3200`
5.  Click **Save & test**.

## 3. Verify Data

### Check Metrics (Prometheus)
1.  In Grafana, go to **Explore**.
2.  Select **Prometheus** datasource.
3.  Query: `up{job="backend-monitor"}`
4.  If result is `1`, your Backend is successfully being scraped!
5.  Try: `rate(http_request_duration_seconds_count[1m])` to see request rates.

### Check Traces (Tempo)
1.  In Grafana, go to **Explore**.
2.  Select **Tempo** datasource.
3.  Click **Search** (Query type).
4.  Run some requests against your app (refresh the Leave System page).
5.  Click **Run Query** in Grafana.
6.  You should see trace IDs appearing from `leave-backend`.

## Troubleshooting
If `tempo-0` pod is stuck in Pending, check the events:
```powershell
kubectl describe pod tempo-0 -n monitoring
```
(It might be waiting for storage provisioning).
