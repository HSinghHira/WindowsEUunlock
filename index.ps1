# Store original GeoID
$origGeo = (Get-WinHomeLocation).GeoId

Set-WinHomeLocation -GeoId 94  # Ireland (EU)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows EU Region Privacy Enabler" -ForegroundColor Cyan
Write-Host "Ultimate Nuclear Option" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "The DeviceRegion key appears to have kernel-level protection." -ForegroundColor Yellow
Write-Host "Let's try a different approach: RENAMING instead of deleting" -ForegroundColor Yellow
Write-Host ""

# Get MinSudo path
Write-Host "Enter the path to the extracted NanaRun folder" -ForegroundColor White
Write-Host "Or press ENTER to use default: C:\Users\$env:USERNAME\Downloads\NanaRun_1.0_Preview3_1.0.92.0" -ForegroundColor Gray
$extractedPath = Read-Host "Path"

if ([string]::IsNullOrWhiteSpace($extractedPath)) {
    $extractedPath = "C:\Users\$env:USERNAME\Downloads\NanaRun_1.0_Preview3_1.0.92.0"
}

$arch = if ([System.Environment]::Is64BitOperatingSystem) { "x64" } else { "Win32" }
$minSudoExe = Join-Path $extractedPath "$arch\MinSudo.exe"

if (!(Test-Path $minSudoExe)) {
    Write-Host "ERROR: MinSudo not found" -ForegroundColor Red
    return
}

# Create script to try renaming or modifying the key instead
$renameScript = @'
$regKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion"

Write-Host "Attempting alternative methods..." -ForegroundColor Cyan
Write-Host ""

# Method 1: Try to RENAME the key instead of delete
Write-Host "Method 1: Renaming the key to DeviceRegion.bak..." -ForegroundColor Yellow
try {
    $parentKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
        "SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel",
        $true
    )
    
    if ($parentKey) {
        # Try to rename by copying to new key and deleting old
        $sourceKey = $parentKey.OpenSubKey("DeviceRegion", $true)
        if ($sourceKey) {
            $valueNames = $sourceKey.GetValueNames()
            
            # Create backup key
            $backupKey = $parentKey.CreateSubKey("DeviceRegion.bak")
            
            # Copy all values
            foreach ($valueName in $valueNames) {
                $value = $sourceKey.GetValue($valueName)
                $valueKind = $sourceKey.GetValueKind($valueName)
                $backupKey.SetValue($valueName, $value, $valueKind)
            }
            
            $backupKey.Close()
            $sourceKey.Close()
            
            # Now try to delete original
            $parentKey.DeleteSubKeyTree("DeviceRegion", $false)
            $parentKey.Close()
            
            Write-Host "SUCCESS: Key renamed/moved!" -ForegroundColor Green
            exit 0
        }
    }
} catch {
    Write-Host "Rename failed: $_" -ForegroundColor Red
}

# Method 2: Delete all VALUES inside the key instead of the key itself
Write-Host ""
Write-Host "Method 2: Deleting all values inside the key..." -ForegroundColor Yellow
try {
    $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
        "SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion",
        $true
    )
    
    if ($key) {
        $valueNames = $key.GetValueNames()
        Write-Host "Found $($valueNames.Count) values to delete" -ForegroundColor Gray
        
        foreach ($valueName in $valueNames) {
            try {
                $key.DeleteValue($valueName)
                Write-Host "  Deleted value: $valueName" -ForegroundColor Green
            } catch {
                Write-Host "  Failed to delete: $valueName - $_" -ForegroundColor Red
            }
        }
        
        $key.Close()
        
        # Check if any values remain
        $checkKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
            "SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion",
            $false
        )
        
        if ($checkKey.GetValueNames().Count -eq 0) {
            Write-Host "SUCCESS: All values deleted! Key is now empty." -ForegroundColor Green
            $checkKey.Close()
            exit 0
        } else {
            Write-Host "Some values remain" -ForegroundColor Yellow
            $checkKey.Close()
        }
    }
} catch {
    Write-Host "Value deletion failed: $_" -ForegroundColor Red
}

# Method 3: Check what's actually in the key
Write-Host ""
Write-Host "Method 3: Inspecting key contents..." -ForegroundColor Yellow
try {
    $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
        "SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion",
        $false
    )
    
    if ($key) {
        Write-Host "Key information:" -ForegroundColor Cyan
        Write-Host "  Subkey count: $($key.SubKeyCount)" -ForegroundColor White
        Write-Host "  Value count: $($key.ValueCount)" -ForegroundColor White
        
        $valueNames = $key.GetValueNames()
        foreach ($valueName in $valueNames) {
            $value = $key.GetValue($valueName)
            Write-Host "  Value: $valueName = $value" -ForegroundColor White
        }
        
        $key.Close()
    }
} catch {
    Write-Host "Inspection failed: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "All alternative methods exhausted." -ForegroundColor Red
exit 1
'@

# Save and run the script
$scriptPath = "$env:TEMP\rename_deviceregion.ps1"
$renameScript | Out-File -FilePath $scriptPath -Encoding UTF8 -Force

Write-Host "Running alternative methods with TrustedInstaller..." -ForegroundColor Cyan
Write-Host ""

& $minSudoExe -U:T -P:E -ShowWindowMode:Show powershell.exe -NoExit -ExecutionPolicy Bypass -File $scriptPath

Start-Sleep -Seconds 3

# Check results
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion") {
    $key = Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion"
    $valueCount = ($key | Get-ItemProperty).PSObject.Properties.Count - 4  # Subtract PowerShell default properties
    
    if ($valueCount -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "PARTIAL SUCCESS!" -ForegroundColor Green
        Write-Host "DeviceRegion key is now EMPTY" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "The key still exists but has no values." -ForegroundColor Yellow
        Write-Host "This may be sufficient for enabling EU privacy options." -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host "Key still exists with values." -ForegroundColor Red
        Write-Host ""
        Write-Host "FINAL RECOMMENDATION:" -ForegroundColor Yellow
        Write-Host "This registry key has unprecedented protection." -ForegroundColor White
        Write-Host "You may need to:" -ForegroundColor White
        Write-Host "  1. Boot from a Windows PE USB" -ForegroundColor Cyan
        Write-Host "  2. Load the offline registry hive" -ForegroundColor Cyan
        Write-Host "  3. Delete the key while Windows isn't running" -ForegroundColor Cyan
    }
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "SUCCESS: DeviceRegion key deleted!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
}

Remove-Item $scriptPath -Force -ErrorAction SilentlyContinue

Start-Process "ms-settings:privacy"

Write-Host ""
Write-Host "Made with love by Harman Singh Hira" -ForegroundColor Gray
Write-Host "https://me.hsinghhira.me" -ForegroundColor Gray