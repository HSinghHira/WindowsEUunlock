# Store original GeoID
$origGeo = (Get-WinHomeLocation).GeoId

Set-WinHomeLocation -GeoId 94  # Ireland (EU)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows EU Region Privacy Enabler" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "INSTRUCTIONS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Download NanaRun manually:" -ForegroundColor White
Write-Host "   Opening download page in your browser..." -ForegroundColor Gray
Start-Process "https://github.com/M2Team/NanaRun/releases/download/1.0.92.0/NanaRun_1.0_Preview3_1.0.92.0.zip"

Write-Host ""
Write-Host "2. Windows Defender will likely block it. To allow it:" -ForegroundColor White
Write-Host "   - Open Windows Security" -ForegroundColor Gray
Write-Host "   - Go to 'Virus & threat protection'" -ForegroundColor Gray
Write-Host "   - Click 'Protection history'" -ForegroundColor Gray
Write-Host "   - Find the blocked NanaRun download" -ForegroundColor Gray
Write-Host "   - Click 'Allow on device'" -ForegroundColor Gray

Write-Host ""
Write-Host "3. Extract the downloaded ZIP file" -ForegroundColor White

Write-Host ""
Write-Host "4. Once extracted, press any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Ask user for the extracted folder location
Write-Host ""
Write-Host "Enter the path to the extracted NanaRun folder" -ForegroundColor Yellow
Write-Host "(e.g., C:\Users\YourName\Downloads\NanaRun_1.0_Preview3_1.0.92.0)" -ForegroundColor Gray
$extractedPath = Read-Host "Path"

$arch = if ([System.Environment]::Is64BitOperatingSystem) { "x64" } else { "Win32" }
$minSudoExe = Join-Path $extractedPath "$arch\MinSudo.exe"

if (Test-Path $minSudoExe) {
    Write-Host ""
    Write-Host "MinSudo found!" -ForegroundColor Green
    Write-Host "Deleting DeviceRegion registry key with TrustedInstaller privileges..." -ForegroundColor Cyan
    Write-Host ""
    
    # Run the deletion command
    $result = & $minSudoExe -U:T -P:E reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion" /f 2>&1
    
    Start-Sleep -Seconds 1
    
    # Verify deletion
    if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion") {
        Write-Host ""
        Write-Host "STATUS: DeviceRegion key still exists" -ForegroundColor Red
        Write-Host "Result: $result" -ForegroundColor Gray
    } else {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "SUCCESS: DeviceRegion key deleted!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
    }
} else {
    Write-Host ""
    Write-Host "ERROR: MinSudo.exe not found at: $minSudoExe" -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure you:" -ForegroundColor Yellow
    Write-Host "1. Extracted the ZIP file" -ForegroundColor White
    Write-Host "2. Entered the correct path to the extracted folder" -ForegroundColor White
}

# Open Settings
Write-Host ""
Write-Host "Opening Windows Settings..." -ForegroundColor Cyan
Start-Process "ms-settings:privacy"

Write-Host ""
Write-Host "Made with love by Harman Singh Hira" -ForegroundColor Gray
Write-Host "https://me.hsinghhira.me" -ForegroundColor Gray