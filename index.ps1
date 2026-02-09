# Run with System privileges using PSExec
# Download PSExec first from: https://live.sysinternals.com/PsExec64.exe

$origGeo = (Get-WinHomeLocation).GeoId
Set-WinHomeLocation -GeoId 242

# Create a temporary script to run as SYSTEM
$systemScript = @'
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion" /f
'@

$systemScript | Out-File -FilePath "$env:TEMP\delete_deviceregion.cmd" -Encoding ASCII

# Run as SYSTEM using PSExec
& .\PsExec64.exe -accepteula -s -i cmd /c "$env:TEMP\delete_deviceregion.cmd"

Remove-Item "$env:TEMP\delete_deviceregion.cmd" -Force

Start-Process "ms-settings:"
Set-WinHomeLocation -GeoId $origGeo

Write-Host "Made with love by Harman Singh Hira"
Write-Host "https://me.hsinghhira.me"