# Store original GeoID
$origGeo = (Get-WinHomeLocation).GeoId

Set-WinHomeLocation -GeoId 94  # Ireland (EU)

Write-Host "Attempting to delete DeviceRegion using SYSTEM privileges with logging..." -ForegroundColor Cyan

# Create a PowerShell script to run as SYSTEM with output logging
$systemScript = @'
$logFile = "$env:TEMP\deviceregion_delete.log"
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion"

"Starting deletion attempt..." | Out-File $logFile

if (Test-Path $regPath) {
    "DeviceRegion key exists. Attempting deletion..." | Out-File $logFile -Append
    
    # Method 1: Direct PowerShell removal
    try {
        Remove-Item -Path $regPath -Recurse -Force -ErrorAction Stop
        "SUCCESS: Deleted with Remove-Item" | Out-File $logFile -Append
    } catch {
        "FAILED Remove-Item: $_" | Out-File $logFile -Append
        
        # Method 2: .NET Registry deletion
        try {
            $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
                "SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel",
                $true
            )
            $key.DeleteSubKeyTree("DeviceRegion")
            $key.Close()
            "SUCCESS: Deleted with .NET DeleteSubKeyTree" | Out-File $logFile -Append
        } catch {
            "FAILED .NET method: $_" | Out-File $logFile -Append
            
            # Method 3: CMD reg delete
            $result = & reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion" /f 2>&1
            "reg.exe result: $result" | Out-File $logFile -Append
        }
    }
    
    # Verify deletion
    if (Test-Path $regPath) {
        "VERIFICATION: Key still exists after deletion attempts" | Out-File $logFile -Append
    } else {
        "VERIFICATION: Key successfully deleted!" | Out-File $logFile -Append
    }
} else {
    "DeviceRegion key does not exist" | Out-File $logFile -Append
}

"Deletion attempt completed." | Out-File $logFile -Append
'@

$systemScript | Out-File -FilePath "$env:TEMP\delete_deviceregion.ps1" -Encoding UTF8 -Force

# Run as SYSTEM using PSExec
Write-Host "Running deletion script as SYSTEM..." -ForegroundColor Yellow
& PsExec64.exe -accepteula -s powershell.exe -ExecutionPolicy Bypass -File "$env:TEMP\delete_deviceregion.ps1"

# Wait a moment for the log to be written
Start-Sleep -Seconds 2

# Read and display the log
if (Test-Path "$env:TEMP\deviceregion_delete.log") {
    Write-Host "`n=== SYSTEM Script Output ===" -ForegroundColor Cyan
    Get-Content "$env:TEMP\deviceregion_delete.log"
    Write-Host "============================`n" -ForegroundColor Cyan
} else {
    Write-Host "Warning: Log file not created" -ForegroundColor Yellow
}

# Verify if the key is gone
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion") {
    Write-Host "STATUS: DeviceRegion key still exists" -ForegroundColor Red
} else {
    Write-Host "STATUS: DeviceRegion key successfully deleted!" -ForegroundColor Green
}

# Cleanup
Remove-Item "$env:TEMP\delete_deviceregion.ps1" -Force -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\deviceregion_delete.log" -Force -ErrorAction SilentlyContinue

# Open Settings
Start-Process "ms-settings:privacy"

Write-Host "`nMade with love by Harman Singh Hira"
Write-Host "https://me.hsinghhira.me"