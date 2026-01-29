# Load Testing & HPA Guide

This guide explains how to stress test the system using k6, verify Auto-Scaling (HPA), and check observability data under load.

## 1. Prerequisites (Resource Limits)
For HPA to work, we added **Resources** to `k8s/backend.yaml`:
*   Request: 250m CPU, 256Mi RAM
*   Limit: 500m CPU, 512Mi RAM

We also created `k8s/backend-hpa.yaml`:
*   **Scale Up**: CPU > 50% or Memory > 70%
*   **Max Replicas**: 5

## 2. Deploy HPA & Updates
Apply the changes to Kubernetes:

```bash
# Update backend with resource limits
kubectl apply -f k8s/backend.yaml

# Create the HPA
kubectl apply -f k8s/backend-hpa.yaml

# Verify HPA exists
kubectl get hpa
```

## 3. Running the Load Test (k6)
You need [k6](https://k6.io/docs/get-started/installation/) installed.

**Run the Test:**

Replace `YOUR_ALB_URL` with your actual Ingress address (e.g., `http://k8s-default-....us-east-1.elb.amazonaws.com`).

```bash
# Set URL as ENV var and run
k6 run -e API_URL=http://YOUR_ALB_URL load-test/script.js
```

**What the Script Does**:
1.  **Registers** a random user.
2.  **Logins** to get a JWT token.
3.  **Applies** for Leave.
4.  **Views** their Leave history.
5.  **Ramps Up**: From 0 -> 20 -> 50 users (concurrent) to spike CPU.

## 4. Observing Results (Real-Time)

While the test is running (~5 minutes), open these tabs:

### A. Watch Kubernetes Scaling (HPA)
Run this in a terminal to watch pods multiply:
```bash
kubectl get hpa -w
# You should see TARGET% go above 50%, and REPLICAS increase from 1 -> 2 -> ... -> 5
```

### B. Watch Grafana
1.  **Metrics**:
    *   Check `rate(http_request_duration_seconds_count[1m])` - Should spike.
    *   Check Latency - Does it degrade as users increase?

2.  **Traces (Tempo)**:
    *   Go to **Explore** -> **Tempo**.
    *   Search for spans during the test window.
    *   Look for "Register" or "Login" spans to see the DB latency.

3.  **Logs (Loki)**:
    *   If you see High Error rates in k6, check Loki: `{app="backend"} |= "error"`.
