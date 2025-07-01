# MySQL Database Setup Guide

## Prerequisites

1. **Install MySQL Server**
   - Download and install MySQL Server from [https://dev.mysql.com/downloads/mysql/](https://dev.mysql.com/downloads/mysql/)
   - Or use Docker: `docker run --name mysql-db -e MYSQL_ROOT_PASSWORD=password -p 3306:3306 -d mysql:8.0`

2. **Install MySQL Workbench** (Optional but recommended)
   - Download from [https://dev.mysql.com/downloads/workbench/](https://dev.mysql.com/downloads/workbench/)

## Database Setup

### Option 1: Using MySQL Command Line

1. **Connect to MySQL:**
   ```bash
   mysql -u root -p
   ```

2. **Create Database:**
   ```sql
   CREATE DATABASE nestjs_auth_db;
   ```

3. **Create User (Optional):**
   ```sql
   CREATE USER 'nestjs_user'@'localhost' IDENTIFIED BY 'secure_password';
   GRANT ALL PRIVILEGES ON nestjs_auth_db.* TO 'nestjs_user'@'localhost';
   FLUSH PRIVILEGES;
   ```

### Option 2: Using Docker

1. **Run MySQL Container:**
   ```bash
   docker run --name mysql-nestjs \
     -e MYSQL_ROOT_PASSWORD=password \
     -e MYSQL_DATABASE=nestjs_auth_db \
     -p 3306:3306 \
     -d mysql:8.0
   ```

2. **Connect to Container (if needed):**
   ```bash
   docker exec -it mysql-nestjs mysql -u root -p
   ```

## Environment Configuration

Update your `.env` file with your MySQL credentials:

```env
# Database Configuration (MySQL)
DB_TYPE=mysql
DB_HOST=localhost
DB_PORT=3306
DB_USERNAME=root
DB_PASSWORD=password
DB_NAME=nestjs_auth_db
DB_SYNCHRONIZE=true
DB_LOGGING=false
```

### Production Settings

For production, make sure to:

1. **Set `DB_SYNCHRONIZE=false`** and use migrations instead
2. **Use strong passwords**
3. **Enable SSL connections**
4. **Set `DB_LOGGING=false`** for better performance

```env
# Production Database Configuration
DB_SYNCHRONIZE=false
DB_LOGGING=false
DB_SSL=true
```

## Connection Testing

To test your database connection, you can use the following commands:

### Test Connection with MySQL Client
```bash
mysql -h localhost -P 3306 -u root -p nestjs_auth_db
```

### Test with Node.js
```javascript
// test-connection.js
const mysql = require('mysql2/promise');

async function testConnection() {
  try {
    const connection = await mysql.createConnection({
      host: 'localhost',
      port: 3306,
      user: 'root',
      password: 'password',
      database: 'nestjs_auth_db'
    });
    
    console.log('✅ Database connection successful!');
    await connection.end();
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
  }
}

testConnection();
```

Run with: `node test-connection.js`

## Troubleshooting

### Common Issues

1. **"Access denied for user"**
   - Check username and password in `.env`
   - Verify user has proper permissions

2. **"Can't connect to MySQL server"**
   - Check if MySQL service is running
   - Verify host and port settings
   - Check firewall settings

3. **"Unknown database"**
   - Create the database: `CREATE DATABASE nestjs_auth_db;`
   - Check database name in `.env`

4. **Connection timeout**
   - Check network connectivity
   - Verify MySQL is accepting connections on the specified port

### Windows MySQL Service

Start/Stop MySQL service on Windows:
```cmd
# Start MySQL
net start mysql80

# Stop MySQL
net stop mysql80
```

### macOS MySQL Service

Start/Stop MySQL service on macOS:
```bash
# Start MySQL
sudo launchctl load -w /Library/LaunchDaemons/com.oracle.oss.mysql.mysqld.plist

# Stop MySQL
sudo launchctl unload -w /Library/LaunchDaemons/com.oracle.oss.mysql.mysqld.plist
```

## Database Schema

When you run the application with `DB_SYNCHRONIZE=true`, TypeORM will automatically create the following table:

```sql
CREATE TABLE `users` (
  `id` varchar(36) NOT NULL,
  `email` varchar(255) NOT NULL,
  `firstName` varchar(255) NOT NULL,
  `lastName` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `refreshToken` text,
  `isActive` tinyint NOT NULL DEFAULT '1',
  `role` varchar(255) NOT NULL DEFAULT 'user',
  `createdAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updatedAt` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `IDX_USER_EMAIL` (`email`)
);
```

## Migration Setup (Production)

For production deployments, use TypeORM migrations instead of synchronization:

1. **Generate migration:**
   ```bash
   npm run typeorm:generate-migration -- --name=InitialMigration
   ```

2. **Run migrations:**
   ```bash
   npm run typeorm:run-migrations
   ```

3. **Add migration scripts to package.json:**
   ```json
   {
     "scripts": {
       "typeorm": "ts-node -r tsconfig-paths/register ./node_modules/typeorm/cli.js",
       "typeorm:generate-migration": "npm run typeorm -- migration:generate",
       "typeorm:run-migrations": "npm run typeorm -- migration:run",
       "typeorm:revert-migration": "npm run typeorm -- migration:revert"
     }
   }
   ```
