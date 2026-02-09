# Store original GeoID
$origGeo = (Get-WinHomeLocation).GeoId

Write-Host "Setting Windows region to EU for privacy options..." -ForegroundColor Cyan

# Set GeoID to a European country (e.g., 94 = Ireland, 242 = Sweden, 84 = France)
Set-WinHomeLocation -GeoId 94

# Set the registry values that control EU privacy features
$regPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy"
)

# Enable EU privacy settings
try {
    # Set region to EEA (European Economic Area)
    if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection")) {
        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Force | Out-Null
    }
    
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force
    
    # Set language/region to EU country
    Set-ItemProperty -Path "HKCU:\Control Panel\International\Geo" -Name "Nation" -Value 94 -Type String -Force
    
    Write-Host "EU region settings applied!" -ForegroundColor Green
    Write-Host "Opening Windows Settings to verify..." -ForegroundColor Yellow
    
} catch {
    Write-Host "Error applying settings: $_" -ForegroundColor Red
}

# Open Settings
Start-Process "ms-settings:privacy"

Write-Host "`nNOTE: You may need to restart Windows for all privacy options to appear." -ForegroundColor Yellow
Write-Host "`nTo revert to your original region later, run:" -ForegroundColor Cyan
Write-Host "Set-WinHomeLocation -GeoId $origGeo" -ForegroundColor White

Write-Host "`nMade with love by Harman Singh Hira"
Write-Host "https://me.hsinghhira.me"