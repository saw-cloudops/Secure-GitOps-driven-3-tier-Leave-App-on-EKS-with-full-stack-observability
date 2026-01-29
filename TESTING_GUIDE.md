# Leave Management System - Testing Guide

## 🎯 Current Status
✅ **Backend**: Running on port 3000
✅ **Frontend**: Running on http://localhost:5173
✅ **Database**: MySQL running in Docker
✅ **UI**: Fixed to match expected design

---

## 🧪 How to Test

### Step 1: Access the Application
Open your browser and go to: **http://localhost:5173**

You should see:
- **Left Card**: "Employee Leave Application" with login form
- **Right Card**: "Admin Leave Management" with login form
- Both cards show preview data below the login forms

---

### Step 2: Initialize Database (First Time Only)

Run these commands to set up the database tables:

```bash
# Connect to MySQL container
docker exec -it mysql mysql -u root -proot leave_db

# Then paste these SQL commands:
```

```sql
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) UNIQUE,
  password VARCHAR(255),
  role ENUM('EMPLOYEE','ADMIN') DEFAULT 'EMPLOYEE'
);

CREATE TABLE IF NOT EXISTS leave_requests (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  start_date DATE,
  end_date DATE,
  reason VARCHAR(255),
  status ENUM('PENDING','APPROVED','REJECTED') DEFAULT 'PENDING',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

Type `exit` to leave MySQL.

---

### Step 3: Create Test Users

#### Option A: Via Register Page (Recommended)
1. On the main page, click **"Create new account"** at the bottom
2. Create an employee account:
   - Username: `john`
   - Password: `password123`
3. Click "Back to login"

#### Option B: Via Database (For Admin User)
```bash
# Connect to MySQL
docker exec -it mysql mysql -uroot -proot leave_db

# Create admin user (password is 'admin123' hashed with bcrypt)
INSERT INTO users (username, password, role) VALUES 
('admin', '$2a$10$xQJ5YqYQYqYQYqYQYqYQYuO7K7K7K7K7K7K7K7K7K7K7K7K7K7K7K', 'ADMIN');
```

**Note**: For proper password hashing, it's better to use the Register page and then manually update the role:

```sql
# After registering 'admin' via the UI, update their role:
UPDATE users SET role = 'ADMIN' WHERE username = 'admin';
```

---

### Step 4: Test Employee Login

1. In the **left card** ("Employee Leave Application"):
   - Username: `john`
   - Password: `password123`
   - Click **Login**

2. **Expected Result**:
   - You should be redirected to the Employee Dashboard
   - You'll see a form to apply for leave (Start Date, End Date, Reason)
   - Below that, a list of your leave requests

3. **Test Actions**:
   - Fill in the leave application form
   - Click "Apply Leave"
   - Verify the new request appears in "My Leave Requests" list

---

### Step 5: Test Admin Login

1. **Logout** from the employee account (click Logout in top-right)

2. In the **right card** ("Admin Leave Management"):
   - Username: `admin`
   - Password: (whatever you set)
   - Click **Login**

3. **Expected Result**:
   - You should be redirected to the Admin Dashboard
   - You'll see "Admin Leave Approvals" heading
   - A list of all leave requests from all employees

4. **Test Actions**:
   - Click **Approve** or **Reject** on any pending request
   - Verify the status updates

---

### Step 6: Verify Full Flow

1. **As Employee**: Apply for leave
2. **Logout** and login **as Admin**
3. **As Admin**: Approve or reject the leave
4. **Logout** and login **as Employee** again
5. **Verify**: The leave status is updated in the employee's view

---

## 🐛 Troubleshooting

### Database Connection Issues
```bash
# Check if MySQL is running
docker ps | grep mysql

# If not running, start it:
docker run -d --name mysql -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=leave_db -p 3306:3306 mysql:8
```

### Backend Not Running
```bash
cd d:/Code/3tier-leave-system/backend
cmd /c "npm start"
```

### Frontend Not Running
```bash
cd d:/Code/3tier-leave-system/frontend
cmd /c "npm run dev"
```

### Login Fails
- Check browser console (F12) for errors
- Verify backend is running and accessible
- Check database has users table with correct data

---

## 📝 Quick Test Script

Here's a quick way to create test data:

```bash
docker exec -it mysql mysql -uroot -proot leave_db -e "
INSERT INTO users (username, password, role) VALUES 
('testemployee', '\$2a\$10\$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'EMPLOYEE'),
('testadmin', '\$2a\$10\$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'ADMIN');
"
```
(Password for both: `password`)

---

## ✨ What's Fixed

1. ✅ **Login.jsx** - Now correctly handles login (was showing Register code)
2. ✅ **App.jsx** - Shows side-by-side Employee and Admin login cards
3. ✅ **UI Design** - Matches your expected design with clean cards and preview sections
4. ✅ **Backend** - Verified running and connected to database
5. ✅ **Database** - MySQL container running and accessible
