# 🪵 How to Monitor Logs (Loki)

We have installed **Loki** (Log Storage) and **Promtail** (Log Collector).
- **Loki**: Stores the logs.
- **Promtail**: Runs on every node, reads logs from pods, and sends them to Loki.

## 1. Configure Loki in Grafana

1.  **Open Grafana**: [http://localhost:3000](http://localhost:3000)
2.  **Add Data Source**:
    *   Menu -> **Connections** -> **Data sources** -> **+ Add new data source**.
    *   Select **Loki**.
    *   **URL**: `http://loki:3100`
    *   Click **Save & test**.
        *   ✅ *Should say "Data source connected and labels found".*

## 2. View Logs

1.  Go to **Explore**.
2.  Select **Loki** from the dropdown.
3.  **Label Filters**:
    *   Select Label: `app`
    *   Select Value: `backend` (or `frontend`, `mysql`)
4.  Click **Run query**.

### Sample Queries (LogQL)
*   **All logs for Backend**:
    ```logql
    {app="backend"}
    ```
*   **Errors only**:
    ```logql
    {app="backend"} |= "error"
    ```
*   **JSON Parsing** (if logs are JSON):
    ```logql
    {app="backend"} | json
    ```

## Troubleshooting
**"No logs found?"**
*   It takes a minute for Promtail to start scraping.
*   Check if Promtail pods are running:
    ```powershell
    kubectl get pods -n monitoring -l app=promtail
    ```
