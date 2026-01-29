# 🏗️ AWS 3-Tier Architecture Deployment Guide

This guide details how to deploy your Leave System using **Auto Scaling Groups (ASG)**, **Application Load Balancer (ALB)**, and **Secure Secrets Management**.

## 1. Architecture Overview

*   **Load Balancer (ALB)**: The single entry point.
    *   `example-alb.us-east-1.elb.amazonaws.com/api/*` ➡️ **Backend Target Group**
    *   `example-alb.us-east-1.elb.amazonaws.com/*` ➡️ **Frontend Target Group**
*   **Frontend Tier**: EC2 instances (ASG) running **Nginx** to serve the React static build.
*   **Backend Tier**: EC2 instances (ASG) running **Node.js**.
*   **Database Tier**: AWS RDS (MySQL).

---

## 2. Secure Your Secrets (SSM Parameter Store)

Instead of hardcoding passwords, we will store them in AWS.

1.  Go to **AWS Systems Manager** > **Parameter Store**.
2.  Click **Create parameter**.
3.  Create the following parameters (Type: **SecureString**):
    *   `/leave-app/production/DB_HOST` -> (Your RDS Endpoint)
    *   `/leave-app/production/DB_USER` -> admin
    *   `/leave-app/production/DB_PASS` -> (Your secure password)
    *   `/leave-app/production/DB_NAME` -> leave_db
    *   `/leave-app/production/JWT_SECRET` -> (A long random string)
    *   `/leave-app/production/API_URL` -> /api  *(Important for Frontend build)*

---

## 3. Create an IAM Role for EC2

Your instances need permission to read those secrets.

1.  Go to **IAM** > **Roles** > **Create role**.
2.  Select **EC2**.
3.  Add Permissions:
    *   `AmazonSSMManagedInstanceCore` (allows you to connect via Session Manager)
    *   Create a generic inline policy allowing `ssm:GetParameters` for the path `/leave-app/*`.
4.  Name the role: `LeaveApp-EC2-Role`.

---

## 4. Backend Deployment (Launch Template)

**Create Launch Template:** `LeaveApp-Backend-LT`
*   **AMI**: Amazon Linux 2023
*   **Instance Type**: t3.micro
*   **IAM Instance Profile**: `LeaveApp-EC2-Role`
*   **Security Group**: Allow port **3000** from ALB Security Group.
*   **User Data (Advanced details)**:

```bash
#!/bin/bash
dnf update -y
dnf install -y nodejs git

# 1. Clone App
cd /home/ec2-user
git clone https://github.com/YOUR_GITHUB_USER/YOUR_REPO_NAME.git app
cd app/backend

# 2. Install Dependencies
npm install

# 3. Fetch Secrets & Create .env securely
# We use aws cli to get parameters and jq to parse them (Amazon Linux 2023 has aws cli installed)
export DB_HOST=$(aws ssm get-parameter --name "/leave-app/production/DB_HOST" --with-decryption --query "Parameter.Value" --output text)
export DB_USER=$(aws ssm get-parameter --name "/leave-app/production/DB_USER" --with-decryption --query "Parameter.Value" --output text)
export DB_PASS=$(aws ssm get-parameter --name "/leave-app/production/DB_PASS" --with-decryption --query "Parameter.Value" --output text)
export DB_NAME=$(aws ssm get-parameter --name "/leave-app/production/DB_NAME" --with-decryption --query "Parameter.Value" --output text)
export JWT_SECRET=$(aws ssm get-parameter --name "/leave-app/production/JWT_SECRET" --with-decryption --query "Parameter.Value" --output text)

# Write to .env file
echo "DB_HOST=$DB_HOST" >> .env
echo "DB_USER=$DB_USER" >> .env
echo "DB_PASS=$DB_PASS" >> .env
echo "DB_NAME=$DB_NAME" >> .env
echo "JWT_SECRET=$JWT_SECRET" >> .env

# 4. Start App (using PM2 for reliability)
npm install -g pm2
pm2 start app.js --name "backend"
pm2 save
pm2 startup
```

---

## 5. Frontend Deployment (Launch Template)

**Create Launch Template:** `LeaveApp-Frontend-LT`
*   **AMI**: Amazon Linux 2023
*   **Instance Type**: t3.small (Need RAM for building)
*   **IAM Instance Profile**: `LeaveApp-EC2-Role`
*   **Security Group**: Allow port **80** from ALB Security Group.
*   **User Data**:

```bash
#!/bin/bash
dnf update -y
dnf install -y nodejs git nginx

# 1. Clone & Build
cd /home/ec2-user
git clone https://github.com/YOUR_GITHUB_USER/YOUR_REPO_NAME.git app
cd app/frontend

npm install

# IMPORTANT: Set API URL to relative path for ALB routing
export VITE_API_URL="/api" 
npm run build

# 2. Move Build to Nginx Web Root
rm -rf /usr/share/nginx/html/*
cp -r dist/* /usr/share/nginx/html/

# 3. Configure Nginx for React (SPA Support)
cat <<EOF > /etc/nginx/conf.d/default.conf
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
EOF

# 4. Start Nginx
systemctl enable nginx
systemctl start nginx
```

---

## 6. Load Balancer (ALB) Setup

1.  Create **Target Group A** (Backend): Port 3000, Health Check `/health`.
2.  Create **Target Group B** (Frontend): Port 80, Health Check `/`.
3.  Create **ALB** (Internet Facing).
4.  **Listeners (Port 80)** rules:
    *   **Rule 1 (Order 1)**: If path is `/api/*` -> Forward to **Backend Target Group**.
    *   **Default Rule**: Forward to **Frontend Target Group**.

---

## 7. Auto Scaling Groups (ASG)

1.  **Backend ASG**: Use `LeaveApp-Backend-LT`. 
    *   Attach to Backend Target Group.
    *   Min: 1, Max: 3.
2.  **Frontend ASG**: Use `LeaveApp-Frontend-LT`. 
    *   Attach to Frontend Target Group.
    *   Min: 1, Max: 3.
