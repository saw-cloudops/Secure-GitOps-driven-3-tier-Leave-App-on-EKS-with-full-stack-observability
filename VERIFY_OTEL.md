# ✅ Application Monitoring Verification

Your application is successfully exposing OpenTelemetry metrics!

## 1. Metrics Verification (Prometheus)

The backend is configured to expose Prometheus metrics on port `9464`.

### Verification Command
Run this command to check if metrics are being generated:

```powershell
# Get the pod name
$POD = kubectl get pods -n leave-system -l app=backend -o jsonpath="{.items[0].metadata.name}"

# Query the metrics endpoint inside the pod
kubectl exec $POD -n leave-system -- wget -qO- http://localhost:9464/metrics
```

**Expected Output:**
You should see output similar to:
```
# HELP target_info Target metadata
# TYPE target_info gauge
target_info{service_name="leave-backend",telemetry_sdk_language="nodejs",...} 1
# HELP http_request_duration_seconds Duration of HTTP requests.
...
```

## 2. Tracing Verification (OTLP)

Your application is configured to send traces via OTLP (OpenTelemetry Protocol).

- **Exporter**: `OTLPTraceExporter`
- **Protocol**: HTTP/Protobuf
- **Default Endpoint**: `http://localhost:4318/v1/traces`

### Current Status
Since no OpenTelemetry Collector (like Tempo or Jaeger) is running in the `leave-system` namespace, these traces are currently being generated but dropped because there is no receiver listening on `localhost:4318` inside the pod.

### How to Fix / Enable Tracing
To collect these traces, you can:

1. **Deploy a Collector**: Install Jaeger or Grafana Tempo in your cluster.
2. **Point to External Collector**: Update the `k3d/backend.yaml` environment variable:
   ```yaml
   env:
     - name: OTEL_EXPORTER_OTLP_ENDPOINT
       value: "http://<collector-ip>:4318/v1/traces"
   ```

## 3. Logs Verification

The application is currently logging to standard output (`stdout`), which Kubernetes captures.

### View Logs
```powershell
kubectl logs -l app=backend -n leave-system -f
```

**Note**: To export logs via OpenTelemetry (OTLP), you would need to add an `OTLPLogExporter` to your `state/instrumentation.js` file, but standard practice in Kubernetes is to let a logging agent (like Promtail or scalar) scrape the stdout logs.
