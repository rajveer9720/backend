# MySQL Setup and Troubleshooting Guide

## Option 1: Update your .env file with correct MySQL credentials

Check your current MySQL credentials and update the .env file:

```env
# Try one of these password configurations:

# Option A: No password (if MySQL was installed without password)
DB_PASSWORD=

# Option B: Default password 'root'
DB_PASSWORD=root

# Option C: Your custom password
DB_PASSWORD=your_mysql_password

# Option D: Empty string for no password
DB_PASSWORD=""
```

## Option 2: Reset MySQL Root Password (if you forgot it)

### On Windows (using MySQL Command Line):

1. Stop MySQL service:
```cmd
net stop mysql
```

2. Start MySQL in safe mode:
```cmd
mysqld --skip-grant-tables
```

3. In another terminal, connect to MySQL:
```cmd
mysql -u root
```

4. Reset the password:
```sql
USE mysql;
UPDATE user SET authentication_string=PASSWORD('root') WHERE user='root';
FLUSH PRIVILEGES;
EXIT;
```

5. Restart MySQL normally:
```cmd
net start mysql
```

## Option 3: Create a new MySQL user

Connect to MySQL as admin and create a new user:

```sql
-- Connect as admin
mysql -u root -p

-- Create new user
CREATE USER 'nestjs_user'@'localhost' IDENTIFIED BY 'nestjs_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON *.* TO 'nestjs_user'@'localhost';

-- Create database
CREATE DATABASE nestjs_auth_db;

-- Grant specific database privileges
GRANT ALL PRIVILEGES ON nestjs_auth_db.* TO 'nestjs_user'@'localhost';

FLUSH PRIVILEGES;
```

Then update your .env:
```env
DB_USERNAME=nestjs_user
DB_PASSWORD=nestjs_password
```

## Option 4: Use XAMPP/WAMP/MAMP

If you're using XAMPP, WAMP, or MAMP:

1. Start Apache and MySQL from the control panel
2. Open phpMyAdmin (usually http://localhost/phpmyadmin)
3. Create a new database called `nestjs_auth_db`
4. Use these credentials in .env:

```env
DB_HOST=localhost
DB_PORT=3306
DB_USERNAME=root
DB_PASSWORD=
DB_NAME=nestjs_auth_db
```

## Option 5: Switch back to SQLite (temporary solution)

If you want to quickly test the app while fixing MySQL:

```env
# Comment out MySQL config and add SQLite
# DB_TYPE=mysql
DB_TYPE=sqlite
DATABASE_URL=database.sqlite
```

And update app.module.ts temporarily to use SQLite.

## Testing Connection

You can test your MySQL connection using this command:
```bash
mysql -h localhost -P 3306 -u root -p
```

Enter your password when prompted. If this works, then use the same credentials in your .env file.
