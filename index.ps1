$origGeo = (Get-WinHomeLocation).GeoId

Set-WinHomeLocation -GeoId 242

Remove-Item “HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion” -Recurse -Force -ErrorAction SilentlyContinue

Start-Process “ms-settings:”

Set-WinHomeLocation -GeoId $origGeo

Write-Host “Made with love by Harman Singh Hira”
Write-Host “https://me.hsinghhira.me”
