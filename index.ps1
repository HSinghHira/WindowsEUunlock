# Store original GeoID
$origGeo = (Get-WinHomeLocation).GeoId

# Change to temporary region
Set-WinHomeLocation -GeoId 242

Write-Host "Deleting DeviceRegion registry key..."

# Use reg delete command directly - this often has better permissions than PowerShell
$process = Start-Process -FilePath "reg" -ArgumentList "delete", "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion", "/f" -Wait -PassThru -NoNewWindow

if ($process.ExitCode -eq 0) {
    Write-Host "DeviceRegion key deleted successfully!" -ForegroundColor Green
} else {
    Write-Host "Could not delete DeviceRegion key. You may need TrustedInstaller permissions." -ForegroundColor Yellow
}

# Open Settings
Start-Process "ms-settings:"

# Restore original region
Set-WinHomeLocation -GeoId $origGeo

Write-Host "Made with love by Harman Singh Hira"
Write-Host "https://me.hsinghhira.me"