# Store original GeoID
$origGeo = (Get-WinHomeLocation).GeoId

Set-WinHomeLocation -GeoId 94  # Ireland (EU)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Windows EU Region Privacy Enabler" -ForegroundColor Cyan
Write-Host "Advanced Registry Key Deletion" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if user has NanaRun extracted
Write-Host "Enter the path to the extracted NanaRun folder" -ForegroundColor Yellow
Write-Host "(e.g., C:\Users\YourName\Downloads\NanaRun_1.0_Preview3_1.0.92.0)" -ForegroundColor Gray
Write-Host "Or press ENTER to use default: C:\Users\$env:USERNAME\Downloads\NanaRun_1.0_Preview3_1.0.92.0" -ForegroundColor Gray
$extractedPath = Read-Host "Path"

if ([string]::IsNullOrWhiteSpace($extractedPath)) {
    $extractedPath = "C:\Users\$env:USERNAME\Downloads\NanaRun_1.0_Preview3_1.0.92.0"
}

$arch = if ([System.Environment]::Is64BitOperatingSystem) { "x64" } else { "Win32" }
$minSudoExe = Join-Path $extractedPath "$arch\MinSudo.exe"

if (!(Test-Path $minSudoExe)) {
    Write-Host ""
    Write-Host "ERROR: MinSudo.exe not found at: $minSudoExe" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please download and extract NanaRun first:" -ForegroundColor Yellow
    Write-Host "https://github.com/M2Team/NanaRun/releases/download/1.0.92.0/NanaRun_1.0_Preview3_1.0.92.0.zip" -ForegroundColor Cyan
    return
}

Write-Host ""
Write-Host "MinSudo found!" -ForegroundColor Green
Write-Host ""

# Create a comprehensive PowerShell script that MinSudo will run
$advancedDeleteScript = @'
$regKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion"
$regKeyPathWin32 = "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion"

Write-Host "Step 1: Taking ownership of the registry key..." -ForegroundColor Yellow

# Method 1: Use SetACL-like approach via PowerShell
try {
    $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
        "SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion",
        [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,
        [System.Security.AccessControl.RegistryRights]::TakeOwnership
    )
    
    if ($key) {
        $acl = $key.GetAccessControl([System.Security.AccessControl.AccessControlSections]::All)
        
        # Set owner to TrustedInstaller (we're running as TI already)
        $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().User
        $acl.SetOwner($currentUser)
        $key.SetAccessControl($acl)
        
        Write-Host "Ownership taken. Granting full control..." -ForegroundColor Yellow
        
        # Grant full control
        $acl = $key.GetAccessControl()
        $rule = New-Object System.Security.AccessControl.RegistryAccessRule(
            $currentUser,
            [System.Security.AccessControl.RegistryRights]::FullControl,
            [System.Security.AccessControl.InheritanceFlags]::ContainerInherit,
            [System.Security.AccessControl.PropagationFlags]::None,
            [System.Security.AccessControl.AccessControlType]::Allow
        )
        $acl.SetAccessRule($rule)
        $key.SetAccessControl($acl)
        $key.Close()
        
        Write-Host "Permissions granted. Attempting deletion..." -ForegroundColor Yellow
        
        # Now try to delete
        Remove-Item -Path $regKeyPath -Recurse -Force -ErrorAction Stop
        Write-Host "SUCCESS: Deleted with Remove-Item!" -ForegroundColor Green
        exit 0
    }
} catch {
    Write-Host "PowerShell method failed: $_" -ForegroundColor Red
}

# Method 2: Use reg.exe commands
Write-Host "Trying reg.exe method..." -ForegroundColor Yellow
$result = reg delete $regKeyPathWin32 /f 2>&1
Write-Host "reg delete result: $result"

# Method 3: Direct registry manipulation
Write-Host "Trying direct .NET deletion..." -ForegroundColor Yellow
try {
    $parentKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
        "SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel",
        $true
    )
    if ($parentKey) {
        $parentKey.DeleteSubKeyTree("DeviceRegion", $false)
        $parentKey.Close()
        Write-Host "SUCCESS: Deleted with DeleteSubKeyTree!" -ForegroundColor Green
        exit 0
    }
} catch {
    Write-Host "Direct deletion failed: $_" -ForegroundColor Red
}

Write-Host "All methods failed!" -ForegroundColor Red
exit 1
'@

# Save the script
$scriptPath = "$env:TEMP\advanced_delete_deviceregion.ps1"
$advancedDeleteScript | Out-File -FilePath $scriptPath -Encoding UTF8 -Force

Write-Host "Running advanced deletion script with TrustedInstaller privileges..." -ForegroundColor Cyan
Write-Host ""

# Execute with MinSudo as TrustedInstaller
& $minSudoExe -U:T -P:E -ShowWindowMode:Show powershell.exe -NoExit -ExecutionPolicy Bypass -File $scriptPath

Write-Host ""
Write-Host "Waiting for script to complete..." -ForegroundColor Gray
Start-Sleep -Seconds 3

# Verify deletion
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion") {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "STATUS: DeviceRegion key STILL exists" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "The registry key appears to be EXTREMELY protected." -ForegroundColor Yellow
    Write-Host "This may be due to:" -ForegroundColor Yellow
    Write-Host "  - Windows actively recreating the key" -ForegroundColor White
    Write-Host "  - Kernel-level protection" -ForegroundColor White
    Write-Host "  - Secure Boot or other security features" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "SUCCESS: DeviceRegion key deleted!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
}

# Cleanup
Remove-Item $scriptPath -Force -ErrorAction SilentlyContinue

# Open Settings
Write-Host ""
Write-Host "Opening Windows Settings..." -ForegroundColor Cyan
Start-Process "ms-settings:privacy"

Write-Host ""
Write-Host "Made with love by Harman Singh Hira" -ForegroundColor Gray
Write-Host "https://me.hsinghhira.me" -ForegroundColor Gray