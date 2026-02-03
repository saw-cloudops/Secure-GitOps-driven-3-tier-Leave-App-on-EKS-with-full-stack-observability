# 🔎 How to Use & Monitor Traces (Beginner Guide)

Tracing allows you to see the "path" of a single request through your system.

## 1. Setup Connection (Do this once)

1.  **Port Forward Grafana**:
    ```powershell
    kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80
    ```
    *(Keep this terminal open)*

2.  **Get Password**:
    ```powershell
    kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | % { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
    ```

3.  **Configure Tempo in Grafana**:
    *   Go to: [http://localhost:3000/connections/datasources/new](http://localhost:3000/connections/datasources/new)
    *   Select **Tempo**.
    *   **URL**: `http://tempo.monitoring.svc.cluster.local:3200`
    *   Click **Save & test**.

## 2. Monitor Traces (Day-to-Day)

### Step A: Generate Traffic
Traces only appear when actions happen.
1.  Open your app: [http://localhost](http://localhost)
2.  Refresh the page, Login, or Submit a Leave Request.

### Step B: Find the Trace
1.  Go to **Grafana > Explore** ([http://localhost:3000/explore](http://localhost:3000/explore)).
2.  Select **Tempo** from the dropdown at the top.
3.  Click **Query Type: Search**.
4.  **Service Name**: Select `leave-backend`.
5.  Click **Run Query**.

### Step C: Analyze
You will see a list of recent requests. Click on one Trace ID.

**You will see:**
*   **Duration**: How long the request took (e.g., 50ms).
*   **Spans**: The individual steps.
    *   *Example*: `POST /api/leave` (Parent)
        *   `auth_middleware` (Child)
        *   `insert_db_query` (Child)

## Troubleshooting
**"No traces found?"**
1.  Ensure you refreshed the app *after* we restarted the backend (traces before the restart were lost).
2.  Wait 10-20 seconds before searching (sometimes there is a slight delay).
3.  Check backend logs to ensure no export errors:
    ```powershell
    kubectl logs -l app=backend -n leave-system
    ```
