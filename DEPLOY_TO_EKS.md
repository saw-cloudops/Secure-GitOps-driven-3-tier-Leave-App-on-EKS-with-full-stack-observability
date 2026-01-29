# Deploying to Amazon EKS with ALB Ingress & SSL

This guide walks you through deploying the Leave Management System to AWS EKS using an Application Load Balancer (ALB) and ACM for SSL.

## 1. Prerequisites (Setup before deploying)

### A. Create an OIDC Provider for the Cluster
This is needed for the AWS Load Balancer Controller to have permissions.
```bash
eksctl utils associate-iam-oidc-provider --region us-east-1 --cluster leave-system-cluster --approve
```

### B. Create IAM Policy
Download the policy:
```bash
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json
```

Create the policy:
```bash
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
```

### C. Create ServiceAccount
Replace `111122223333` with your AWS Account ID.
```bash
eksctl create iamserviceaccount \
  --cluster=leave-system-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name "AmazonEKSLoadBalancerControllerRole" \
  --attach-policy-arn=arn:aws:iam::111122223333:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```

### D. Install AWS Load Balancer Controller (using Helm)
```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=leave-system-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller 
```

### E. Request a Certificate in ACM
1.  Go to **AWS Certificate Manager (ACM)**.
2.  Request a public certificate.
3.  Enter your domain name (e.g., `leave-app.example.com`).
4.  Validate the certificate (DNS validation).
5.  **Copy the Certificate ARN**.

---

## 2. Build & Push Images
(Same as before, but ensure you rebuild because we changed code)

```bash
# Backend
cd backend
docker build -t yourusername/leave-backend:latest .
docker push yourusername/leave-backend:latest
cd ..

# Frontend
cd frontend
docker build -t yourusername/leave-frontend:latest .
docker push yourusername/leave-frontend:latest
cd ..
```

---

## 3. Deploy Application

1.  **Secrets & Database**:
    ```bash
    kubectl apply -f k8s/secrets.yaml
    kubectl apply -f k8s/mysql.yaml
    ```

2.  **Deploy Backend & Frontend**:
    Edit `k8s/backend.yaml` and `k8s/frontend.yaml` with your image names if needed.
    ```bash
    kubectl apply -f k8s/backend.yaml
    kubectl apply -f k8s/frontend.yaml
    ```

3.  **Configure Ingress**:
    Open `k8s/ingress.yaml`:
    *   **Replace** `alb.ingress.kubernetes.io/certificate-arn` with your actual ACM Certificate ARN.
    
    Then apply:
    ```bash
    kubectl apply -f k8s/ingress.yaml
    ```

4.  **Verify**:
    Wait for the ALB to be provisioned (can take 5 mins).
    ```bash
    kubectl get ingress leave-ingress
    ```
    Copy the `ADDRESS` (e.g., `k8s-default-leaveing-....us-east-1.elb.amazonaws.com`).

5.  **DNS Mapping**:
    Go to your DNS provider (Route53, GoDaddy, etc.) and create a CNAME record:
    *   `leave-app.example.com` -> `k8s-default-leaveing-....us-east-1.elb.amazonaws.com`

---

## Architecture Note
*   **Frontend**: Served at root `/`
*   **Backend**: Served at `/api`
*   **SSL**: Terminated at the ALB. Traffic inside the cluster is HTTP.
