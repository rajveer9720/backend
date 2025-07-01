# NestJS Authentication API

A complete CRUD authentication and authorization REST API built with NestJS, featuring JWT tokens, refresh tokens, and role-based access control.

## Features

- ✅ User registration and authentication
- ✅ JWT access tokens with short expiration (15 minutes)
- ✅ Refresh tokens with longer expiration (7 days)
- ✅ Role-based authorization (user/admin)
- ✅ Password hashing with bcrypt
- ✅ CRUD operations for user management
- ✅ MySQL database with TypeORM
- ✅ Input validation with class-validator
- ✅ Global exception handling
- ✅ Response interceptor for consistent API responses
- ✅ CORS enabled for frontend integration
- ✅ IP filtering for production security
- ✅ New Relic monitoring support
- ✅ Custom logging with AppLogger

## Installation

```bash
npm install
```

## Environment Variables

Create a `.env` file in the root directory:

```env
# Application Configuration
PORT=7001
MODE=development

# Database Configuration (MySQL)
DB_TYPE=mysql
DB_HOST=localhost
DB_PORT=3306
DB_USERNAME=root
DB_PASSWORD=password
DB_NAME=nestjs_auth_db
DB_SYNCHRONIZE=true
DB_LOGGING=false

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-here
JWT_EXPIRES_IN=15m
JWT_REFRESH_SECRET=your-super-secret-refresh-jwt-key-here
JWT_REFRESH_EXPIRES_IN=7d

# Security Configuration
IP_ADDRESS=127.0.0.1,::1

# New Relic Configuration (Optional)
NEW_RELIC_APP_NAME=NestJS-Auth-API
NEW_RELIC_LICENSE_KEY=your-newrelic-license-key
NEW_RELIC_LOG_LEVEL=info
```

## Database Setup

Before running the application, you need to set up MySQL:

1. **Install MySQL Server** or use Docker:
   ```bash
   docker run --name mysql-nestjs -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=nestjs_auth_db -p 3306:3306 -d mysql:8.0
   ```

2. **Create Database** (if not using Docker):
   ```sql
   CREATE DATABASE nestjs_auth_db;
   ```

For detailed MySQL setup instructions, see [MYSQL_SETUP.md](MYSQL_SETUP.md).

## Running the Application

```bash
# Development
npm run start:dev

# Production
npm run build
npm run start:prod
```

The API will be available at `http://localhost:7001/api/v1`

## API Endpoints

### Authentication

#### Register User
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "password": "password123"
}
```

#### Login
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

Response:
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "user"
  },
  "accessToken": "jwt-access-token",
  "refreshToken": "jwt-refresh-token"
}
```

#### Refresh Token
```http
POST /api/auth/refresh
Content-Type: application/json

{
  "refreshToken": "your-refresh-token"
}
```

#### Logout
```http
POST /api/auth/logout
Authorization: Bearer your-access-token
```

### User Management

#### Get Current User Profile
```http
GET /api/users/profile
Authorization: Bearer your-access-token
```

#### Update Profile
```http
PATCH /api/users/profile
Authorization: Bearer your-access-token
Content-Type: application/json

{
  "firstName": "Updated Name",
  "lastName": "Updated Last Name"
}
```

#### Change Password
```http
POST /api/users/change-password
Authorization: Bearer your-access-token
Content-Type: application/json

{
  "currentPassword": "oldpassword",
  "newPassword": "newpassword123"
}
```

### Admin Operations (Admin Role Required)

#### Get All Users
```http
GET /api/users
Authorization: Bearer admin-access-token
```

#### Create User (Admin)
```http
POST /api/users
Authorization: Bearer admin-access-token
Content-Type: application/json

{
  "email": "newuser@example.com",
  "firstName": "New",
  "lastName": "User",
  "password": "password123",
  "role": "user"
}
```

#### Get User by ID
```http
GET /api/users/:id
Authorization: Bearer admin-access-token
```

#### Update User
```http
PATCH /api/users/:id
Authorization: Bearer admin-access-token
Content-Type: application/json

{
  "firstName": "Updated",
  "lastName": "Name",
  "role": "admin",
  "isActive": false
}
```

#### Delete User
```http
DELETE /api/users/:id
Authorization: Bearer admin-access-token
```

## Security Features

1. **Password Security**: Passwords are hashed using bcrypt with salt rounds of 12
2. **JWT Security**: Separate secrets for access and refresh tokens
3. **Token Expiration**: Short-lived access tokens (15m) and longer refresh tokens (7d)
4. **Refresh Token Storage**: Refresh tokens are hashed and stored in the database
5. **Role-based Access**: Admin-only endpoints for user management
6. **Input Validation**: All inputs are validated using class-validator
7. **CORS Protection**: Configured for specific frontend origins

## Database Schema

### User Entity
- `id`: UUID (Primary Key)
- `email`: String (Unique)
- `firstName`: String
- `lastName`: String
- `password`: String (Hashed)
- `refreshToken`: String (Hashed, Nullable)
- `isActive`: Boolean (Default: true)
- `role`: String (Default: 'user')
- `createdAt`: DateTime
- `updatedAt`: DateTime

## Error Handling

The API returns appropriate HTTP status codes and error messages:

- `400 Bad Request`: Invalid input data
- `401 Unauthorized`: Invalid credentials or expired token
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `409 Conflict`: Resource already exists
- `500 Internal Server Error`: Server error

## Testing with curl

### Register a new user:
```bash
curl -X POST http://localhost:3001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "firstName": "Test",
    "lastName": "User",
    "password": "password123"
  }'
```

### Login:
```bash
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### Access protected route:
```bash
curl -X GET http://localhost:3001/api/users/profile \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Frontend Integration

This API is designed to work with React applications. The frontend should:

1. Store access and refresh tokens securely
2. Include access token in Authorization header for protected requests
3. Implement automatic token refresh when access token expires
4. Handle authentication state management

Example RTK Query setup for frontend integration is available in the `rtkquery` folder.
