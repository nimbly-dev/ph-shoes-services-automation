# Check nginx status on EC2 instances
$instances = @("54.254.31.158", "18.138.255.153", "13.213.50.175")

foreach ($ip in $instances) {
    Write-Host "`n=== Checking Instance $ip ===" -ForegroundColor Yellow
    
    # Test if nginx is responding on port 80
    Write-Host "Testing nginx on port 80..." -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri "http://${ip}:80" -Method GET -TimeoutSec 5 -Headers @{"Host" = "accounts.phshoesproject.com"}
        Write-Host "✅ Nginx responding: $($response.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Nginx not responding on port 80: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Test direct backend service
    Write-Host "Testing direct backend service on port 8082..." -ForegroundColor Cyan
    try {
        $response = Invoke-WebRequest -Uri "http://${ip}:8082/api/v1/system/status" -Method GET -TimeoutSec 5
        Write-Host "✅ Backend service responding: $($response.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "❌ Backend service not responding: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`n=== Testing via Cloudflare ===" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://accounts.phshoesproject.com/api/v1/system/status" -Method GET -TimeoutSec 10
    Write-Host "✅ Cloudflare proxy working: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "❌ Cloudflare proxy failing: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}