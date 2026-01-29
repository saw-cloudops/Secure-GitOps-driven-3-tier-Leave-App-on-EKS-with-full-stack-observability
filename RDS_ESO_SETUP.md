# Moving to AWS RDS & External Secrets Operator

This guide explains how to migrate to a production-grade database setup and manage secrets securely without committing them to Git.

## 1. Setup AWS RDS (Database)
1.  Go to **AWS RDS Console** -> **Create Database**.
2.  Choose **MySQL**.
3.  Choose **Free Tier** or **Production**.
4.  **Settings**:
    *   **DB Instance ID**: `leave-db-prod`
    *   **Master Username**: `admin`
    *   **Master Password**: *Generate a strong password*.
5.  **Connectivity**:
    *   **VPC Security Group**: Create new `rds-sg`.
    *   **Public Access**: No (Connect via VPN/Bastion) or Yes (for dev/test).
6.  **Create**.
7.  **Get Endpoint**: Once ready, copy the endpoint (e.g., `leave-db-prod.xxx.us-east-1.rds.amazonaws.com`).

## 2. Setup AWS Secrets Manager
1.  Go to **AWS Secrets Manager**.
2.  **Store a new secret**.
3.  Choose **Other type of secret**.
4.  **Key/Value Pairs**:
    *   `host`: (Your RDS Endpoint)
    *   `username`: `admin`
    *   `password`: (Your RDS Password)
    *   `dbname`: `leave_db`
    *   `jwt_secret`: (A long random string)
5.  **Secret Name**: `prod/leave-system/db`
6.  **Create**.

## 3. Install External Secrets Operator (ESO)
We use Helm to install ESO.

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

helm install external-secrets external-secrets/external-secrets \
    -n external-secrets \
    --create-namespace \
    --set installCRDs=true
```

## 4. Configure IAM Permissions (IRSA)
Cluster needs permission to read Secrets Manager.

1.  **Create IAM Policy** (`ESO-Secrets-Policy`):
    ```json
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ],
          "Resource": "arn:aws:secretsmanager:us-east-1:YOUR_ACCOUNT_ID:secret:prod/leave-system/db-*"
        }
      ]
    }
    ```

2.  **Create IAM Service Account**:
    ```bash
    eksctl create iamserviceaccount \
      --name external-secrets-sa \
      --namespace external-secrets \
      --cluster leave-system-cluster \
      --attach-policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/ESO-Secrets-Policy \
      --approve \
      --override-existing-serviceaccounts
    ```

## 5. Deploy Secret Store & sync
Now we tell K8s to fetch the secret.

```bash
# Register the Store (AWS Provider)
kubectl apply -f k8s/eso-store.yaml

# Create the Sync (Maps AWS -> K8s Secret 'db-secrets')
kubectl apply -f k8s/eso-secret.yaml
```

**Verify**:
```bash
kubectl get secret db-secrets
# You should see your secrets synced!
```

## 6. Deploy Backend
Update your backend to use the new RDS connection.

```bash
kubectl apply -f k8s/backend.yaml
```

## Cleanup Old Resources
Since we use RDS now, we deleted `k8s/mysql.yaml` and the local network policies.
