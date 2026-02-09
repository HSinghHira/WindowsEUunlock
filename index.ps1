# Store original GeoID
$origGeo = (Get-WinHomeLocation).GeoId

Set-WinHomeLocation -GeoId 94  # Ireland (EU)

Write-Host "Attempting to delete DeviceRegion using SYSTEM privileges..." -ForegroundColor Cyan

# Create a PowerShell script to run as SYSTEM
$systemScript = @'
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion"
if (Test-Path $regPath) {
    # Take ownership
    $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
        "SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel",
        $true
    )
    
    # Try to delete the subkey
    try {
        $key.DeleteSubKeyTree("DeviceRegion", $false)
        Write-Output "SUCCESS"
    } catch {
        Write-Output "FAILED: $_"
    }
    $key.Close()
} else {
    Write-Output "KEY_NOT_FOUND"
}
'@

$systemScript | Out-File -FilePath "$env:TEMP\delete_deviceregion.ps1" -Encoding UTF8 -Force

# Run as SYSTEM using PSExec
$result = & PsExec64.exe -accepteula -s -i powershell.exe -ExecutionPolicy Bypass -File "$env:TEMP\delete_deviceregion.ps1" 2>&1

Write-Host "Result: $result"

Remove-Item "$env:TEMP\delete_deviceregion.ps1" -Force -ErrorAction SilentlyContinue

# Open Settings
Start-Process "ms-settings:privacy"

Write-Host "`nMade with love by Harman Singh Hira"
Write-Host "https://me.hsinghhira.me"