# Store original GeoID
$origGeo = (Get-WinHomeLocation).GeoId

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Windows EU Region Privacy Enabler" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will:" -ForegroundColor White
Write-Host "  1. Add temporary Windows Defender exclusion" -ForegroundColor Gray
Write-Host "  2. Download NanaRun automatically" -ForegroundColor Gray
Write-Host "  3. Delete DeviceRegion registry values" -ForegroundColor Gray
Write-Host "  4. Enable EU privacy options" -ForegroundColor Gray
Write-Host "  5. Clean up and remove exclusion" -ForegroundColor Gray
Write-Host ""

# Set up paths
$nanarunDir = "$env:TEMP\NanaRun_WinEU"
$nanarunUrl = "https://github.com/M2Team/NanaRun/releases/download/1.0.92.0/NanaRun_1.0_Preview3_1.0.92.0.zip"
$nanarunZip = "$nanarunDir\NanaRun.zip"
$nanarunExtracted = "$nanarunDir\Extracted"

# Create directory
if (!(Test-Path $nanarunDir)) {
    New-Item -Path $nanarunDir -ItemType Directory -Force | Out-Null
}

# Step 1: Add Windows Defender exclusion
Write-Host "[1/5] Adding Windows Defender exclusion..." -ForegroundColor Yellow
try {
    Add-MpPreference -ExclusionPath $nanarunDir -ErrorAction Stop
    Write-Host "      ✓ Exclusion added for: $nanarunDir" -ForegroundColor Green
} catch {
    Write-Host "      ⚠ Could not add exclusion: $_" -ForegroundColor Red
    Write-Host "      Continuing anyway..." -ForegroundColor Yellow
}
Write-Host ""

# Step 2: Download NanaRun
Write-Host "[2/5] Downloading NanaRun..." -ForegroundColor Yellow
try {
    $ProgressPreference = 'SilentlyContinue'  # Faster downloads
    Invoke-WebRequest -Uri $nanarunUrl -OutFile $nanarunZip -UseBasicParsing -ErrorAction Stop
    Write-Host "      ✓ Downloaded successfully" -ForegroundColor Green
} catch {
    Write-Host "      ✗ Download failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please download manually from:" -ForegroundColor Yellow
    Write-Host "$nanarunUrl" -ForegroundColor Cyan
    
    # Remove exclusion
    Remove-MpPreference -ExclusionPath $nanarunDir -ErrorAction SilentlyContinue
    return
}
Write-Host ""

# Step 3: Extract NanaRun
Write-Host "[3/5] Extracting NanaRun..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $nanarunZip -DestinationPath $nanarunExtracted -Force -ErrorAction Stop
    Write-Host "      ✓ Extracted successfully" -ForegroundColor Green
} catch {
    Write-Host "      ✗ Extraction failed: $_" -ForegroundColor Red
    
    # Remove exclusion and cleanup
    Remove-MpPreference -ExclusionPath $nanarunDir -ErrorAction SilentlyContinue
    Remove-Item -Path $nanarunDir -Recurse -Force -ErrorAction SilentlyContinue
    return
}
Write-Host ""

# Find MinSudo.exe
$arch = if ([System.Environment]::Is64BitOperatingSystem) { "x64" } else { "Win32" }
$minSudoExe = "$nanarunExtracted\$arch\MinSudo.exe"

if (!(Test-Path $minSudoExe)) {
    Write-Host "      ✗ MinSudo.exe not found at: $minSudoExe" -ForegroundColor Red
    
    # Remove exclusion and cleanup
    Remove-MpPreference -ExclusionPath $nanarunDir -ErrorAction SilentlyContinue
    Remove-Item -Path $nanarunDir -Recurse -Force -ErrorAction SilentlyContinue
    return
}

# Step 4: Delete DeviceRegion registry values
Write-Host "[4/5] Deleting DeviceRegion registry values..." -ForegroundColor Yellow

# Set region to EU
Set-WinHomeLocation -GeoId 94  # Ireland (EU)

# Create the deletion script
$deleteScript = @'
$regKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion"

try {
    $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
        "SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion",
        $true
    )
    
    if ($key) {
        $valueNames = $key.GetValueNames()
        
        foreach ($valueName in $valueNames) {
            try {
                $key.DeleteValue($valueName)
            } catch {
                # Silently continue
            }
        }
        
        $key.Close()
        
        # Verify all values are deleted
        $checkKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
            "SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion",
            $false
        )
        
        if ($checkKey.GetValueNames().Count -eq 0) {
            exit 0  # Success
        } else {
            exit 1  # Some values remain
        }
    } else {
        exit 2  # Key doesn't exist
    }
} catch {
    exit 3  # Error occurred
}
'@

$scriptPath = "$nanarunDir\delete_deviceregion.ps1"
$deleteScript | Out-File -FilePath $scriptPath -Encoding UTF8 -Force

# Run with MinSudo (silently)
$process = Start-Process -FilePath $minSudoExe -ArgumentList "-U:T", "-P:E", "-ShowWindowMode:Hide", "powershell.exe", "-ExecutionPolicy", "Bypass", "-File", "`"$scriptPath`"" -Wait -PassThru -NoNewWindow

# Check exit code
if ($process.ExitCode -eq 0) {
    Write-Host "      ✓ DeviceRegion values deleted successfully!" -ForegroundColor Green
} elseif ($process.ExitCode -eq 2) {
    Write-Host "      ℹ DeviceRegion key doesn't exist (already removed)" -ForegroundColor Cyan
} else {
    Write-Host "      ⚠ Some values may remain (Exit code: $($process.ExitCode))" -ForegroundColor Yellow
}
Write-Host ""

# Step 5: Cleanup
Write-Host "[5/5] Cleaning up..." -ForegroundColor Yellow

# Remove Windows Defender exclusion
try {
    Remove-MpPreference -ExclusionPath $nanarunDir -ErrorAction Stop
    Write-Host "      ✓ Defender exclusion removed" -ForegroundColor Green
} catch {
    Write-Host "      ⚠ Could not remove exclusion (you may need to remove it manually)" -ForegroundColor Yellow
}

# Delete temporary files
Start-Sleep -Milliseconds 500
Remove-Item -Path $nanarunDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "      ✓ Temporary files removed" -ForegroundColor Green
Write-Host ""

# Final verification
Write-Host "========================================" -ForegroundColor Cyan
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion") {
    $key = Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion"
    $properties = $key | Get-ItemProperty
    $valueCount = ($properties.PSObject.Properties | Where-Object { $_.Name -notmatch '^PS' }).Count
    
    if ($valueCount -eq 0) {
        Write-Host "  ✓ SUCCESS!" -ForegroundColor Green
        Write-Host "  DeviceRegion key is now empty" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ PARTIAL SUCCESS" -ForegroundColor Yellow
        Write-Host "  Some values may remain" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ✓ SUCCESS!" -ForegroundColor Green
    Write-Host "  DeviceRegion key deleted" -ForegroundColor Green
}
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Open Windows Settings
Write-Host "Opening Windows Privacy Settings..." -ForegroundColor Cyan
Start-Process "ms-settings:privacy"

Write-Host ""
Write-Host "EU privacy options should now be available!" -ForegroundColor Green
Write-Host "You may need to restart Windows for all changes to take effect." -ForegroundColor Yellow
Write-Host ""
Write-Host "To revert to your original region, run:" -ForegroundColor Gray
Write-Host "Set-WinHomeLocation -GeoId $origGeo" -ForegroundColor White
Write-Host ""
Write-Host "Made with love by Harman Singh Hira" -ForegroundColor Gray
Write-Host "https://me.hsinghhira.me" -ForegroundColor Gray
Write-Host ""