# Store original GeoID and create restore script
$origGeo = (Get-WinHomeLocation).GeoId

# Create a restore script in user's Documents folder
$restoreScriptPath = "$env:USERPROFILE\Documents\Restore_Original_Region.ps1"
$restoreScript = @"
# Restore Original Windows Region
# Created: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

Write-Host "Restoring your original Windows region..." -ForegroundColor Cyan
Set-WinHomeLocation -GeoId $origGeo
Write-Host "Region restored to GeoID: $origGeo" -ForegroundColor Green
Write-Host ""
Write-Host "Press any key to exit..."
`$null = `$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
"@

$restoreScript | Out-File -FilePath $restoreScriptPath -Encoding UTF8 -Force

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
Write-Host "ℹ A restore script has been saved to:" -ForegroundColor Cyan
Write-Host "  $restoreScriptPath" -ForegroundColor White
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
$exclusionAdded = $false
try {
    Add-MpPreference -ExclusionPath $nanarunDir -ErrorAction Stop
    Write-Host "      ✓ Exclusion added for: $nanarunDir" -ForegroundColor Green
    $exclusionAdded = $true
} catch {
    Write-Host "      ⚠ Could not add exclusion: $_" -ForegroundColor Red
    Write-Host "      This might be due to third-party antivirus or Tamper Protection" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "      MANUAL STEPS REQUIRED:" -ForegroundColor Yellow
    Write-Host "      1. Open Windows Security" -ForegroundColor White
    Write-Host "      2. Go to 'Virus & threat protection'" -ForegroundColor White
    Write-Host "      3. Click 'Manage settings' under 'Virus & threat protection settings'" -ForegroundColor White
    Write-Host "      4. Scroll down and turn OFF 'Tamper Protection'" -ForegroundColor White
    Write-Host "      5. Go back and click 'Manage settings' again" -ForegroundColor White
    Write-Host "      6. Scroll to 'Exclusions' and click 'Add or remove exclusions'" -ForegroundColor White
    Write-Host "      7. Add this folder: $nanarunDir" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "      Press any key after adding the exclusion to continue..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Write-Host ""
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
    Write-Host "      This is likely due to Windows Defender or antivirus blocking the download." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "      MANUAL STEPS TO DISABLE WINDOWS DEFENDER:" -ForegroundColor Yellow
    Write-Host "      1. Open Windows Security (search in Start menu)" -ForegroundColor White
    Write-Host "      2. Click 'Virus & threat protection'" -ForegroundColor White
    Write-Host "      3. Click 'Manage settings' under 'Virus & threat protection settings'" -ForegroundColor White
    Write-Host "      4. Turn OFF 'Real-time protection'" -ForegroundColor White
    Write-Host "      5. Turn OFF 'Cloud-delivered protection'" -ForegroundColor White
    Write-Host "      6. Turn OFF 'Automatic sample submission'" -ForegroundColor White
    Write-Host ""
    Write-Host "      IF YOU HAVE THIRD-PARTY ANTIVIRUS (Norton, McAfee, Avast, etc.):" -ForegroundColor Yellow
    Write-Host "      1. Open your antivirus program" -ForegroundColor White
    Write-Host "      2. Look for 'Settings' or 'Options'" -ForegroundColor White
    Write-Host "      3. Temporarily disable 'Real-time protection' or 'Shield'" -ForegroundColor White
    Write-Host "      4. Add $nanarunDir to exclusions/whitelist" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "      After disabling protection, press any key to retry download..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Write-Host ""
    Write-Host "      Retrying download..." -ForegroundColor Yellow
    
    try {
        Invoke-WebRequest -Uri $nanarunUrl -OutFile $nanarunZip -UseBasicParsing -ErrorAction Stop
        Write-Host "      ✓ Downloaded successfully on retry!" -ForegroundColor Green
    } catch {
        Write-Host "      ✗ Download still failed." -ForegroundColor Red
        Write-Host ""
        Write-Host "      ALTERNATIVE: Manual download" -ForegroundColor Yellow
        Write-Host "      1. Open this link in your browser:" -ForegroundColor White
        Write-Host "         $nanarunUrl" -ForegroundColor Cyan
        Write-Host "      2. Save the file to: $nanarunZip" -ForegroundColor Cyan
        Write-Host "      3. Press any key to continue..." -ForegroundColor White
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        if (!(Test-Path $nanarunZip)) {
            Write-Host ""
            Write-Host "      ✗ File not found. Exiting..." -ForegroundColor Red
            if ($exclusionAdded) {
                Remove-MpPreference -ExclusionPath $nanarunDir -ErrorAction SilentlyContinue
            }
            return
        }
    }
}
Write-Host ""

# Step 3: Extract NanaRun
Write-Host "[3/5] Extracting NanaRun..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $nanarunZip -DestinationPath $nanarunExtracted -Force -ErrorAction Stop
    Write-Host "      ✓ Extracted successfully" -ForegroundColor Green
} catch {
    Write-Host "      ✗ Extraction failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "      The downloaded file may be corrupted or blocked." -ForegroundColor Yellow
    Write-Host "      Try the following:" -ForegroundColor Yellow
    Write-Host "      1. Right-click on: $nanarunZip" -ForegroundColor Cyan
    Write-Host "      2. Select 'Properties'" -ForegroundColor White
    Write-Host "      3. At the bottom, check if there's an 'Unblock' checkbox" -ForegroundColor White
    Write-Host "      4. If yes, check it and click 'Apply'" -ForegroundColor White
    Write-Host "      5. Press any key to retry extraction..." -ForegroundColor White
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    try {
        # Try to unblock the file programmatically
        Unblock-File -Path $nanarunZip -ErrorAction SilentlyContinue
        Expand-Archive -Path $nanarunZip -DestinationPath $nanarunExtracted -Force -ErrorAction Stop
        Write-Host "      ✓ Extracted successfully on retry!" -ForegroundColor Green
    } catch {
        Write-Host "      ✗ Extraction still failed." -ForegroundColor Red
        
        # Cleanup
        if ($exclusionAdded) {
            Remove-MpPreference -ExclusionPath $nanarunDir -ErrorAction SilentlyContinue
        }
        Remove-Item -Path $nanarunDir -Recurse -Force -ErrorAction SilentlyContinue
        return
    }
}
Write-Host ""

# Find MinSudo.exe
$arch = if ([System.Environment]::Is64BitOperatingSystem) { "x64" } else { "Win32" }
$minSudoExe = "$nanarunExtracted\$arch\MinSudo.exe"

if (!(Test-Path $minSudoExe)) {
    Write-Host "      ✗ MinSudo.exe not found at: $minSudoExe" -ForegroundColor Red
    
    # Cleanup
    if ($exclusionAdded) {
        Remove-MpPreference -ExclusionPath $nanarunDir -ErrorAction SilentlyContinue
    }
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
try {
    $process = Start-Process -FilePath $minSudoExe -ArgumentList "-U:T", "-P:E", "-ShowWindowMode:Hide", "powershell.exe", "-ExecutionPolicy", "Bypass", "-File", "`"$scriptPath`"" -Wait -PassThru -NoNewWindow -ErrorAction Stop

    # Check exit code
    if ($process.ExitCode -eq 0) {
        Write-Host "      ✓ DeviceRegion values deleted successfully!" -ForegroundColor Green
    } elseif ($process.ExitCode -eq 2) {
        Write-Host "      ℹ DeviceRegion key doesn't exist (already removed)" -ForegroundColor Cyan
    } else {
        Write-Host "      ⚠ Some values may remain (Exit code: $($process.ExitCode))" -ForegroundColor Yellow
    }
} catch {
    Write-Host "      ✗ MinSudo execution failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "      This is likely because antivirus is blocking MinSudo from running." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "      STEPS TO ALLOW MINSUDO:" -ForegroundColor Yellow
    Write-Host "      1. Open Windows Security" -ForegroundColor White
    Write-Host "      2. Go to 'Virus & threat protection'" -ForegroundColor White
    Write-Host "      3. Click 'Protection history'" -ForegroundColor White
    Write-Host "      4. Find 'MinSudo.exe' in the list" -ForegroundColor White
    Write-Host "      5. Click on it and select 'Allow on device'" -ForegroundColor White
    Write-Host ""
    Write-Host "      OR add MinSudo to exclusions:" -ForegroundColor Yellow
    Write-Host "      1. In Windows Security, go to 'Virus & threat protection'" -ForegroundColor White
    Write-Host "      2. Click 'Manage settings'" -ForegroundColor White
    Write-Host "      3. Scroll to 'Exclusions' and click 'Add or remove exclusions'" -ForegroundColor White
    Write-Host "      4. Add this file: $minSudoExe" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "      Press any key after allowing MinSudo to retry..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    # Retry
    try {
        $process = Start-Process -FilePath $minSudoExe -ArgumentList "-U:T", "-P:E", "-ShowWindowMode:Hide", "powershell.exe", "-ExecutionPolicy", "Bypass", "-File", "`"$scriptPath`"" -Wait -PassThru -NoNewWindow -ErrorAction Stop
        
        if ($process.ExitCode -eq 0) {
            Write-Host "      ✓ DeviceRegion values deleted successfully on retry!" -ForegroundColor Green
        } else {
            Write-Host "      ⚠ Completed with exit code: $($process.ExitCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "      ✗ Still failed. Please check antivirus settings." -ForegroundColor Red
    }
}
Write-Host ""

# Step 5: Cleanup
Write-Host "[5/5] Cleaning up..." -ForegroundColor Yellow

# Remove Windows Defender exclusion
if ($exclusionAdded) {
    try {
        Remove-MpPreference -ExclusionPath $nanarunDir -ErrorAction Stop
        Write-Host "      ✓ Defender exclusion removed" -ForegroundColor Green
    } catch {
        Write-Host "      ⚠ Could not remove exclusion (you may need to remove it manually)" -ForegroundColor Yellow
    }
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
Write-Host "ℹ To restore your original region, run this file:" -ForegroundColor Cyan
Write-Host "  $restoreScriptPath" -ForegroundColor White
Write-Host "  (Just double-click it or right-click → Run with PowerShell)" -ForegroundColor Gray
Write-Host ""
Write-Host "Made with love by Harman Singh Hira" -ForegroundColor Gray
Write-Host "https://me.hsinghhira.me" -ForegroundColor Gray
Write-Host ""