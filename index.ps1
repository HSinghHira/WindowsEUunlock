# Store original GeoID
$origGeo = (Get-WinHomeLocation).GeoId

# Change to temporary region
Set-WinHomeLocation -GeoId 242

$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion"

Write-Host "Checking if DeviceRegion exists..."
if (Test-Path $regPath) {
    Write-Host "DeviceRegion key found. Attempting advanced deletion..."
    
    # Method: Use .NET Registry classes with TakeOwnership
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    
    public class RegistryRights {
        [DllImport("advapi32.dll", SetLastError = true)]
        public static extern int RegOpenKeyEx(UIntPtr hKey, string subKey, int ulOptions, int samDesired, out UIntPtr hkResult);
        
        [DllImport("advapi32.dll", SetLastError = true)]
        public static extern int RegDeleteKey(UIntPtr hKey, string subKey);
        
        [DllImport("advapi32.dll", SetLastError = true)]
        public static extern int RegCloseKey(UIntPtr hKey);
        
        public const int KEY_ALL_ACCESS = 0xF003F;
        public static readonly UIntPtr HKEY_LOCAL_MACHINE = new UIntPtr(0x80000002u);
    }
"@
    
    try {
        $subKey = "SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion"
        [UIntPtr]$hKey = [UIntPtr]::Zero
        
        $result = [RegistryRights]::RegDeleteKey([RegistryRights]::HKEY_LOCAL_MACHINE, $subKey)
        
        if ($result -eq 0) {
            Write-Host "DeviceRegion deleted via Win32 API!" -ForegroundColor Green
        } else {
            Write-Host "Win32 API deletion failed with code: $result" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
    
    # Verify if it's still there
    Start-Sleep -Milliseconds 500
    if (Test-Path $regPath) {
        Write-Host "WARNING: DeviceRegion key still exists - Windows may be protecting/recreating it" -ForegroundColor Yellow
    } else {
        Write-Host "SUCCESS: DeviceRegion key is gone!" -ForegroundColor Green
    }
}

# Open Settings
Start-Process "ms-settings:"

# Restore original region
Set-WinHomeLocation -GeoId $origGeo

Write-Host "Made with love by Harman Singh Hira"
Write-Host "https://me.hsinghhira.me"