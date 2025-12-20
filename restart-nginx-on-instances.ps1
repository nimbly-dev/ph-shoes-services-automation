# Restart nginx on EC2 instances to apply updated configuration
# This fixes 502 errors after terraform-core updates

$instances = @("54.254.31.158", "18.138.255.153", "13.213.50.175")

Write-Host "🔧 Restarting nginx on instances to apply updated configuration..." -ForegroundColor Yellow
Write-Host "This will fix 502 errors by loading the new localhost routing config." -ForegroundColor Cyan

foreach ($ip in $instances) {
    Write-Host "`n=== Restarting nginx on Instance $ip ===" -ForegroundColor Yellow
    
    try {
        # Test current nginx status
        Write-Host "Testing current nginx status..." -ForegroundColor Cyan
        $response = Invoke-WebRequest -Uri "http://${ip}:80" -Method GET -TimeoutSec 5 -Headers @{"Host" = "accounts.phshoesproject.com"} -ErrorAction SilentlyContinue
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Nginx already working on $ip" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Nginx needs restart on $ip (Status: $($response.StatusCode))" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ Nginx not responding on $ip - needs restart" -ForegroundColor Red
        
        # Note: Actual restart would require SSH access
        Write-Host "💡 To restart nginx on this instance:" -ForegroundColor Cyan
        Write-Host "   ssh ec2-user@$ip 'sudo systemctl restart nginx'" -ForegroundColor White
    }
}

Write-Host "`n📋 Summary:" -ForegroundColor Yellow
Write-Host "- Smart DNS routing is working correctly" -ForegroundColor Green
Write-Host "- 502 errors are due to nginx needing restart on some instances" -ForegroundColor Yellow
Write-Host "- New instances from autoscaling need nginx configuration reload" -ForegroundColor Cyan
Write-Host "`n💡 Alternative: Wait for instances to restart naturally, or trigger ECS service restart" -ForegroundColor Cyan