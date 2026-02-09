# Store original GeoID
$origGeo = (Get-WinHomeLocation).GeoId

# Change to temporary region
Set-WinHomeLocation -GeoId 242

# Take ownership and delete DeviceRegion key
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion"

if (Test-Path $regPath) {
    Write-Host "Taking ownership of DeviceRegion key..."
    
    # Enable privilege to take ownership
    $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey(
        "SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion",
        [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,
        [System.Security.AccessControl.RegistryRights]::TakeOwnership
    )
    
    if ($key) {
        $acl = $key.GetAccessControl()
        $acl.SetOwner([System.Security.Principal.WindowsIdentity]::GetCurrent().User)
        $key.SetAccessControl($acl)
        
        # Grant full control to current user
        $acl = $key.GetAccessControl()
        $rule = New-Object System.Security.AccessControl.RegistryAccessRule(
            [System.Security.Principal.WindowsIdentity]::GetCurrent().User,
            [System.Security.AccessControl.RegistryRights]::FullControl,
            [System.Security.AccessControl.InheritanceFlags]::ContainerInherit,
            [System.Security.AccessControl.PropagationFlags]::None,
            [System.Security.AccessControl.AccessControlType]::Allow
        )
        $acl.AddAccessRule($rule)
        $key.SetAccessControl($acl)
        $key.Close()
        
        Write-Host "Deleting DeviceRegion key..."
        Remove-Item $regPath -Recurse -Force -ErrorAction Stop
        Write-Host "DeviceRegion key deleted successfully!"
    }
} else {
    Write-Host "DeviceRegion key not found."
}

# Open Settings
Start-Process "ms-settings:"

# Restore original region
Set-WinHomeLocation -GeoId $origGeo

Write-Host "Made with love by Harman Singh Hira"
Write-Host "https://me.hsinghhira.me"