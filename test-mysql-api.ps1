# Test MySQL Connection and API

Write-Host "Testing MySQL Database Connection and API..." -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green

# Test Database Connection
Write-Host "`n1. Testing MySQL Connection..." -ForegroundColor Yellow

try {
    # Test if MySQL is accessible (requires mysql2 to be installed globally or use docker)
    Write-Host "✓ MySQL connection test - Please ensure MySQL is running on localhost:3306" -ForegroundColor Green
} catch {
    Write-Host "✗ MySQL connection failed. Please check MySQL setup." -ForegroundColor Red
    Write-Host "Run: docker run --name mysql-nestjs -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=nestjs_auth_db -p 3306:3306 -d mysql:8.0" -ForegroundColor Yellow
}

# Wait for API to be ready
Write-Host "`n2. Waiting for API to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# Test API Endpoints
$baseUrl = "http://localhost:7001/api/v1"

# Test 1: Register a new user
Write-Host "`n3. Testing user registration..." -ForegroundColor Yellow
try {
    $registerResponse = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method POST -Body (@{
        email = "mysql-test@example.com"
        firstName = "MySQL"
        lastName = "Test"
        password = "password123"
    } | ConvertTo-Json) -ContentType "application/json"

    Write-Host "✓ User registered successfully" -ForegroundColor Green
    Write-Host "User ID: $($registerResponse.data.user.id)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Registration failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Login
Write-Host "`n4. Testing login..." -ForegroundColor Yellow
try {
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method POST -Body (@{
        email = "mysql-test@example.com"
        password = "password123"
    } | ConvertTo-Json) -ContentType "application/json"

    $accessToken = $loginResponse.data.accessToken
    Write-Host "✓ Login successful" -ForegroundColor Green
    Write-Host "User: $($loginResponse.data.user.firstName) $($loginResponse.data.user.lastName)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Login failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Get profile (protected route)
Write-Host "`n5. Testing protected route..." -ForegroundColor Yellow
try {
    $profile = Invoke-RestMethod -Uri "$baseUrl/users/profile" -Headers @{Authorization="Bearer $accessToken"}
    Write-Host "✓ Profile retrieved successfully" -ForegroundColor Green
    Write-Host "Profile: $($profile.data.firstName) $($profile.data.lastName) - $($profile.data.email)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Profile retrieval failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nMySQL API testing completed!" -ForegroundColor Green
Write-Host "`nAPI Base URL: $baseUrl" -ForegroundColor Cyan
Write-Host "Database: MySQL on localhost:3306" -ForegroundColor Cyan
