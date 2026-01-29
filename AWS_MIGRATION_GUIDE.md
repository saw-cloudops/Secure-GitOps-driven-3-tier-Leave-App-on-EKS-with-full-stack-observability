# ☁️ Moving to AWS RDS: Migration Guide

This guide will help you move your database from local Docker to AWS RDS (Relational Database Service), making your application production-ready.

## 1. The SQL Schema (Enhanced)

Your current SQL is good, but for production, we should add a foreign key to link `leave_requests` to `users`. This prevents "orphan" data.

Use this SQL script for your RDS database:

```sql
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role ENUM('EMPLOYEE','ADMIN') DEFAULT 'EMPLOYEE'
);

CREATE TABLE leave_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  reason VARCHAR(255),
  status ENUM('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

> **Note**: `ON DELETE CASCADE` means if you delete a user, all their leave requests will be automatically deleted too.

---

## 2. Create the RDS Instance

1.  Log in to the **AWS Console**.
2.  Go to **RDS** service.
3.  Click **Create database**.
4.  **Choose a database creation method**: Standard create.
5.  **Engine options**: MySQL.
6.  **Templates**: Free tier (if eligible) or Dev/Test.
7.  **Settings**:
    *   **DB instance identifier**: `leave-system-db` (or any name)
    *   **Master username**: `admin` (or your choice)
    *   **Master password**: Create a strong password (and write it down!)
8.  **Connectivity**:
    *   **Public access**: **Yes** (if you want to connect from your local PC to test) or **No** (for better security, if connecting only from EC2). *For now, you might want 'Yes' to run your SQL script easily.*
    *   **VPC security group**: Create new. Name it something like `rds-access-sg`.
9.  Click **Create database**.

It will take 5-10 minutes to start.

---

## 3. Configure Network Access (Security Group)

Once the database is "Available":

1.  Click on the database name.
2.  Under **Connectivity & security**, click the link under **VPC security groups** (e.g., `rds-access-sg`).
3.  Go to the **Inbound rules** tab -> **Edit inbound rules**.
4.  Add Rule:
    *   **Type**: MYSQL/Aurora (Port 3306)
    *   **Source**: `My IP` (This allows YOUR computer to connect).
    *   *Later, when deploying the backend to EC2, you will add another rule allowing the EC2 instance's Security Group.*

---

## 4. setup the Database Tables

Now you need to run the SQL query on the new AWS RDS server.

1.  **Get the Endpoint**: Go to your RDS database page in AWS Console. Copy the **Endpoint** URL (e.g., `leave-system-db.cxyz.us-east-1.rds.amazonaws.com`).
2.  **Connect via Terminal/Command Prompt**:
    ```bash
    mysql -h <YOUR_RDS_ENDPOINT> -u admin -p
    ```
    *(Enter the password you created in step 2)*
3.  **Create and Use Database**:
    ```sql
    CREATE DATABASE leave_db;
    USE leave_db;
    ```
4.  **Run the Schema**: Paste the SQL code from Section 1 above.
5.  **Create Admin User** (Optional but recommended so you can log in immediately):
    ```sql
    INSERT INTO users (username, password, role) VALUES ('admin', '$2a$10$YourHashedPasswordHere', 'ADMIN');
    ```
    *(Note: You'll need a bcrypt hashed password. You can generate one using an online bcrypt generator or just register a new user locally and copy their hashed password).*

---

## 5. Connect Your Backend

Finally, update your backend to talk to AWS instead of Docker.

**If running locally (testing):**
Update your `.env` file:
```env
DB_HOST=<YOUR_RDS_ENDPOINT>
DB_USER=admin
DB_PASS=<YOUR_RDS_PASSWORD>
DB_NAME=leave_db
JWT_SECRET=your-secret-key
```

**If running on EC2:**
You will pass these values as environment variables or create an `.env` file on the server.

---

## ✅ Checklist
- [ ] RDS Instance Created (MySQL)
- [ ] Security Group allows port 3306 from your IP
- [ ] Connected to RDS and ran `CREATE TABLE` scripts
- [ ] Backend configured with new `DB_HOST`, `DB_USER`, and `DB_PASS`
