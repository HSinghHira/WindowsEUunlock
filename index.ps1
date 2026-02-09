# Ensure you run this in an Elevated PowerShell (Admin) window
$regPath = "SOFTWARE\Microsoft\Windows\CurrentVersion\Control Panel\DeviceRegion"
$fullPath = "HKLM:\$regPath"

if (Test-Path $fullPath) {
    Write-Host "Key found. Attempting to take ownership..." -ForegroundColor Cyan
    
    # 1. Take Ownership
    $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($regPath, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree, [System.Security.AccessControl.RegistryRights]::TakeOwnership)
    $acl = $key.GetAccessControl()
    $me = [System.Security.Principal.NTAccount]"Administrators"
    $acl.SetOwner($me)
    $key.SetAccessControl($acl)

    # 2. Grant Full Control to Administrators
    $acl = $key.GetAccessControl()
    $rule = New-Object System.Security.AccessControl.RegistryAccessRule("Administrators", "FullControl", "Allow")
    $acl.SetAccessRule($rule)
    $key.SetAccessControl($acl)
    $key.Close()

    # 3. Now try to delete
    try {
        Remove-Item -Path $fullPath -Recurse -Force
        Write-Host "SUCCESS: DeviceRegion key deleted!" -ForegroundColor Green
    } catch {
        Write-Host "Deletion failed: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "Key not found. Nothing to delete." -ForegroundColor Yellow
}