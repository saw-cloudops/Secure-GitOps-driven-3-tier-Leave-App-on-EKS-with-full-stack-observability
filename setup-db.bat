@echo off
echo ========================================
echo Setting up test users for Leave System
echo ========================================
echo.

echo Creating database tables...
docker exec -i mysql mysql -uroot -proot leave_db < db.sql

echo.
echo Database tables created!
echo.
echo You can now:
echo 1. Open http://localhost:5173 in your browser
echo 2. Click "Create new account" to register users
echo 3. Register an employee (e.g., username: john, password: password123)
echo 4. To make an admin, register a user then run:
echo    docker exec -it mysql mysql -uroot -proot leave_db -e "UPDATE users SET role='ADMIN' WHERE username='yourusername';"
echo.
echo ========================================
echo Setup complete!
echo ========================================
pause
