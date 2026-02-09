# Store original GeoID
$origGeo = (Get-WinHomeLocation).GeoId

# Change to temporary region
Set-WinHomeLocation -GeoId 242

Write-Host "Taking ownership from TrustedInstaller..."

# Define the registry key path
$regKeyPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion"

# Step 1: Take ownership of the registry key
$null = & takeown /f $regKeyPath /a /r /d Y 2>&1

# Step 2: Grant Administrators full control
# We need to use the subinacl or icacls equivalent for registry
# Using REG command to set permissions
$adminSID = "S-1-5-32-544"  # Administrators group SID
$null = & reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion" /f 2>&1

# Step 3: Give full control to Administrators group using PowerShell
try {
    $acl = Get-Acl "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion"
    $administrators = [System.Security.Principal.SecurityIdentifier]::new("S-1-5-32-544")
    $rule = New-Object System.Security.AccessControl.RegistryAccessRule(
        $administrators,
        [System.Security.AccessControl.RegistryRights]::FullControl,
        [System.Security.AccessControl.InheritanceFlags]::ContainerInherit,
        [System.Security.AccessControl.PropagationFlags]::None,
        [System.Security.AccessControl.AccessControlType]::Allow
    )
    $acl.SetAccessRule($rule)
    Set-Acl "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion" $acl
    
    Write-Host "Permissions updated. Deleting registry key..."
    
    # Step 4: Now delete the key
    Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion" -Recurse -Force
    Write-Host "DeviceRegion key deleted successfully!" -ForegroundColor Green
    
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    Write-Host "Trying alternative method with reg.exe..."
    
    # Alternative: Use reg.exe with correct syntax
    & reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion" /f
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "DeviceRegion key deleted successfully!" -ForegroundColor Green
    } else {
        Write-Host "Still unable to delete. The key may regenerate immediately." -ForegroundColor Yellow
    }
}

# Open Settings
Start-Process "ms-settings:"

# Restore original region
Set-WinHomeLocation -GeoId $origGeo

Write-Host "Made with love by Harman Singh Hira"
Write-Host "https://me.hsinghhira.me"