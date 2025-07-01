# Simple API Test Script

# Test 1: Register a new user
Write-Host "1. Registering new user..." -ForegroundColor Yellow
$registerResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/auth/register" -Method POST -Body (@{
    email = "demo@example.com"
    firstName = "Demo"
    lastName = "User"
    password = "password123"
} | ConvertTo-Json) -ContentType "application/json"

Write-Host "✓ User registered: $($registerResponse.user.firstName) $($registerResponse.user.lastName)" -ForegroundColor Green

# Test 2: Login
Write-Host "`n2. Logging in..." -ForegroundColor Yellow
$loginResponse = Invoke-RestMethod -Uri "http://localhost:3001/api/auth/login" -Method POST -Body (@{
    email = "demo@example.com"
    password = "password123"
} | ConvertTo-Json) -ContentType "application/json"

$accessToken = $loginResponse.accessToken
Write-Host "✓ Login successful" -ForegroundColor Green

# Test 3: Get profile
Write-Host "`n3. Getting profile..." -ForegroundColor Yellow
$profile = Invoke-RestMethod -Uri "http://localhost:3001/api/users/profile" -Headers @{Authorization="Bearer $accessToken"}
Write-Host "✓ Profile: $($profile.firstName) $($profile.lastName) - $($profile.email)" -ForegroundColor Green

# Test 4: Update profile
Write-Host "`n4. Updating profile..." -ForegroundColor Yellow
$updatedProfile = Invoke-RestMethod -Uri "http://localhost:3001/api/users/profile" -Method PATCH -Body (@{
    firstName = "Updated Demo"
    lastName = "Updated User"
} | ConvertTo-Json) -Headers @{Authorization="Bearer $accessToken"; "Content-Type"="application/json"}

Write-Host "✓ Profile updated: $($updatedProfile.firstName) $($updatedProfile.lastName)" -ForegroundColor Green

Write-Host "`nAll tests completed successfully!" -ForegroundColor Green
