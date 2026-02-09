# Store original GeoID
$origGeo = (Get-WinHomeLocation).GeoId

Set-WinHomeLocation -GeoId 94  # Ireland (EU)

Write-Host "Downloading NanaRun (MinSudo)..." -ForegroundColor Cyan

# Create temp directory for NanaRun
$nanarunDir = "$env:TEMP\NanaRun"
if (!(Test-Path $nanarunDir)) {
    New-Item -Path $nanarunDir -ItemType Directory -Force | Out-Null
}

# Download NanaRun
$nanarunUrl = "https://github.com/M2Team/NanaRun/releases/download/1.0.92.0/NanaRun_1.0_Preview3_1.0.92.0.zip"
$nanarunZip = "$nanarunDir\NanaRun.zip"
$nanarunExtracted = "$nanarunDir\Extracted"

try {
    Write-Host "Downloading NanaRun from GitHub..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $nanarunUrl -OutFile $nanarunZip -UseBasicParsing
    
    Write-Host "Extracting NanaRun..." -ForegroundColor Yellow
    Expand-Archive -Path $nanarunZip -DestinationPath $nanarunExtracted -Force
    
    # Determine architecture and find MinSudo.exe
    $arch = if ([System.Environment]::Is64BitOperatingSystem) { "x64" } else { "Win32" }
    $minSudoExe = "$nanarunExtracted\$arch\MinSudo.exe"
    
    if (Test-Path $minSudoExe) {
        Write-Host "MinSudo found successfully!" -ForegroundColor Green
        Write-Host "Using: $minSudoExe" -ForegroundColor Gray
        
        # Create deletion batch script (simpler and more reliable for reg delete)
        $deleteScript = @'
@echo off
echo ========================================
echo Deleting DeviceRegion registry key...
echo ========================================
echo.

reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion" /f

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo SUCCESS: DeviceRegion key deleted!
    echo ========================================
) else (
    echo.
    echo ========================================
    echo FAILED: Could not delete DeviceRegion key
    echo Error code: %errorlevel%
    echo ========================================
)

echo.
echo Press any key to close this window...
pause >nul
'@
        
        $deleteScriptPath = "$nanarunDir\delete_deviceregion.bat"
        $deleteScript | Out-File -FilePath $deleteScriptPath -Encoding ASCII -Force
        
        Write-Host "`nLaunching MinSudo with TrustedInstaller privileges..." -ForegroundColor Cyan
        Write-Host "A command prompt window will open - please wait for the result." -ForegroundColor Yellow
        Write-Host ""
        
        # MinSudo command format: MinSudo.exe -U:T -P:E <command>
        # -U:T = TrustedInstaller user
        # -P:E = Elevated privilege
        & $minSudoExe -U:T -P:E cmd.exe /c $deleteScriptPath
        
        # Wait a moment for the operation to complete
        Start-Sleep -Seconds 2
        
        # Verify if the key is gone
        Write-Host "`nVerifying deletion..." -ForegroundColor Cyan
        if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion") {
            Write-Host "STATUS: DeviceRegion key still exists" -ForegroundColor Red
            Write-Host "The key may be protected or instantly recreated by Windows." -ForegroundColor Yellow
        } else {
            Write-Host "STATUS: DeviceRegion key successfully deleted!" -ForegroundColor Green
        }
        
    } else {
        Write-Host "ERROR: Could not find MinSudo.exe at expected path: $minSudoExe" -ForegroundColor Red
        Write-Host "Available files:" -ForegroundColor Gray
        Get-ChildItem -Path $nanarunExtracted -Recurse | ForEach-Object { Write-Host "  $($_.FullName)" -ForegroundColor Gray }
    }
    
} catch {
    Write-Host "ERROR: Failed to download or extract NanaRun: $_" -ForegroundColor Red
    Write-Host "You can manually download NanaRun from: https://github.com/M2Team/NanaRun/releases" -ForegroundColor Yellow
}

# Cleanup
Write-Host "`nCleaning up temporary files..." -ForegroundColor Gray
Start-Sleep -Seconds 2
Remove-Item -Path $nanarunDir -Recurse -Force -ErrorAction SilentlyContinue

# Open Settings
Start-Process "ms-settings:privacy"

Write-Host "`nMade with love by Harman Singh Hira"
Write-Host "https://me.hsinghhira.me"