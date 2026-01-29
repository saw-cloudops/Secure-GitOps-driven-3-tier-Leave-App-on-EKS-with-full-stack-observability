# GitOps Pipeline Guide: GitLab CI + EKS + ArgoCD

This guide explains how to set up the complete GitOps pipeline.

## 1. Setup ECR Repositories (AWS)
Create two repositories in AWS ECR (Elastic Container Registry):
*   `leave-backend`
*   `leave-frontend`

## 2. Configure GitLab CI/CD Variables
Go to your GitLab Repository -> Settings -> CI/CD -> Variables.
Add these variables (Protected & Masked recommended):

*   `AWS_ACCESS_KEY_ID`: Your AWS Access Key.
*   `AWS_SECRET_ACCESS_KEY`: Your AWS Secret Key.
*   `AWS_REGION`: e.g., `us-east-1`.
*   `ECR_REGISTRY`: Your ECR URL (e.g., `123456789012.dkr.ecr.us-east-1.amazonaws.com`).
    *   *Note: Do not include the repo name here, just the base registry URL.*

## 3. Verify Codebase
Ensure `.gitlab-ci.yml` matches your repository names.
*   The `sed` commands in the CI file look for `leave-backend` and `leave-frontend` strings to replace the image line.

## 4. Install ArgoCD on EKS
If you haven't installed ArgoCD yet:
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

**Access the UI**:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
*   Open `localhost:8080`
*   Username: `admin`
*   Password:
    ```bash
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    ```

## 5. Configure ArgoCD Application
1.  **Edit** `argocd/application.yaml`:
    *   Find the `repoURL` field.
    *   **Change it** to your actual GitLab repository URL (e.g., `https://gitlab.com/username/repo.git`).

2.  **Apply the Application**:
    ```bash
    kubectl apply -f argocd/application.yaml
    ```

## 6. How It Works
1.  **Push Code**: You push code to `main`.
2.  **CI Trigger**: GitLab CI starts.
    *   Builds Docker images.
    *   Pushes to ECR with Short SHA tag (e.g., `:a1b2c3d`).
    *   **Updates Manifests**: The CI job edits `k8s/backend.yaml` and `k8s/frontend.yaml` to point to the new image tag.
    *   **Git Push**: The CI job commits this change back to your `main` branch.
3.  **CD Sync**: ArgoCD detects the change in the git repository (the `k8s/` folder) and automatically syncs the new deployment to EKS.
