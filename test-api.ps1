# PowerShell script to test the API endpoints

Write-Host "Testing NestJS Authentication API" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# 1. Register a new user
Write-Host "`n1. Testing user registration..." -ForegroundColor Yellow
$registerBody = @{
    email = "testuser@example.com"
    firstName = "Test"
    lastName = "User"
    password = "password123"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/auth/register" -Method POST -Body $registerBody -ContentType "application/json"
    Write-Host "✓ User registered successfully" -ForegroundColor Green
    Write-Host "User ID: $($registerResponse.user.id)" -ForegroundColor Cyan
    Write-Host "Access Token: $($registerResponse.accessToken.Substring(0, 20))..." -ForegroundColor Cyan
} catch {
    Write-Host "✗ Registration failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 2. Login with the user
Write-Host "`n2. Testing user login..." -ForegroundColor Yellow
$loginBody = @{
    email = "testuser@example.com"
    password = "password123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json"
    Write-Host "✓ Login successful" -ForegroundColor Green
    $accessToken = $loginResponse.accessToken
    $refreshToken = $loginResponse.refreshToken
    Write-Host "User: $($loginResponse.user.firstName) $($loginResponse.user.lastName)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Login failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Get user profile
Write-Host "`n3. Testing protected route (get profile)..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

try {
    $profileResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/users/profile" -Method GET -Headers $headers
    Write-Host "✓ Profile retrieved successfully" -ForegroundColor Green
    Write-Host "Profile: $($profileResponse.firstName) $($profileResponse.lastName) - $($profileResponse.email)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Profile retrieval failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. Update profile
Write-Host "`n4. Testing profile update..." -ForegroundColor Yellow
$updateBody = @{
    firstName = "Updated Test"
    lastName = "Updated User"
} | ConvertTo-Json

try {
    $updateResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/users/profile" -Method PATCH -Body $updateBody -Headers $headers
    Write-Host "✓ Profile updated successfully" -ForegroundColor Green
    Write-Host "Updated: $($updateResponse.firstName) $($updateResponse.lastName)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Profile update failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. Test refresh token
Write-Host "`n5. Testing refresh token..." -ForegroundColor Yellow
$refreshBody = @{
    refreshToken = $refreshToken
} | ConvertTo-Json

try {
    $refreshResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/auth/refresh" -Method POST -Body $refreshBody -ContentType "application/json"
    Write-Host "✓ Token refreshed successfully" -ForegroundColor Green
    Write-Host "New Access Token: $($refreshResponse.accessToken.Substring(0, 20))..." -ForegroundColor Cyan
} catch {
    Write-Host "✗ Token refresh failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 6. Register admin user
Write-Host "`n6. Testing admin user registration..." -ForegroundColor Yellow
$adminRegisterBody = @{
    email = "admin@example.com"
    firstName = "Admin"
    lastName = "User"
    password = "admin123"
    role = "admin"
} | ConvertTo-Json

try {
    $adminRegisterResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/auth/register" -Method POST -Body $adminRegisterBody -ContentType "application/json"
    Write-Host "✓ Admin user registered successfully" -ForegroundColor Green
    $adminAccessToken = $adminRegisterResponse.accessToken
} catch {
    Write-Host "✗ Admin registration failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 7. Test admin route - get all users
Write-Host "`n7. Testing admin route (get all users)..." -ForegroundColor Yellow
$adminHeaders = @{
    "Authorization" = "Bearer $adminAccessToken"
    "Content-Type" = "application/json"
}

try {
    $allUsersResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/users" -Method GET -Headers $adminHeaders
    Write-Host "✓ All users retrieved successfully" -ForegroundColor Green
    Write-Host "Total users: $($allUsersResponse.Count)" -ForegroundColor Cyan
    foreach ($user in $allUsersResponse) {
        Write-Host "  - $($user.firstName) $($user.lastName) ($($user.role))" -ForegroundColor Gray
    }
} catch {
    Write-Host "✗ Get all users failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 8. Logout
Write-Host "`n8. Testing logout..." -ForegroundColor Yellow
try {
    Invoke-RestMethod -Uri "http://localhost:3001/api/auth/logout" -Method POST -Headers $headers
    Write-Host "✓ Logout successful" -ForegroundColor Green
} catch {
    Write-Host "✗ Logout failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nAPI testing completed!" -ForegroundColor Green
