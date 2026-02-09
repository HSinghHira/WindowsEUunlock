# Store original GeoID
$origGeo = (Get-WinHomeLocation).GeoId

# Change to temporary region
Set-WinHomeLocation -GeoId 242

# Delete DeviceRegion key using reg.exe with force
$regPath = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion"

if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion") {
    Write-Host "Attempting to delete DeviceRegion key..."
    
    # Take ownership using takeown
    $takeownResult = & takeown /f "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion" /r /d y 2>&1
    
    # Grant permissions using icacls (for registry, we use reg command)
    & reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion" /f 2>&1 | Out-Null
    
    # Delete the key
    $deleteResult = & reg delete $regPath /f 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "DeviceRegion key deleted successfully!"
    } else {
        Write-Host "Failed to delete DeviceRegion key. Error: $deleteResult"
    }
} else {
    Write-Host "DeviceRegion key not found."
}

# Open Settings
Start-Process "ms-settings:"

# Restore original region
Set-WinHomeLocation -GeoId $origGeo

Write-Host "Made with love by Harman Singh Hira"
Write-Host "https://me.hsinghhira.me"