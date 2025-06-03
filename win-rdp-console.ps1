<# CONTENT AUTHORING  Edit Application Setup Below This Line #>

# Load the Default user profile
reg load "HKU\TempHive" "C:\Users\Default\NTUSER.DAT"

# Set the HKU registry keys (vulnerability)
New-Item -Path "Registry::HKU\TempHive\Software\Policies\Microsoft\Windows\" -Name "Installer" -Force
Set-ItemProperty -Path "Registry::HKU\TempHive\Software\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 1 -Type DWord
Set-ItemProperty -Path "Registry::HKU\TempHive\Software\Policies\Microsoft\Windows\Installer" -Name "DisableMSI" -Value 0 -Type DWord

# Set the HKLM registry keys (vulnerability)
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\" -Name "Installer" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 1 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer" -Name "DisableMSI" -Value 0 -Type DWord

# Create a local user account for lab - this is the assumed breach
$pwd = ConvertTo-SecureString "P@ssword123" -AsPlainText -Force
New-LocalUser -Name "max.overdrive" -Password $pwd -FullName "Maxwell Overdrive" -Description "Chief Visionary Officer."

# Add the user to Remote Desktop Users group
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "max.overdrive"

# Create the Tools directory
New-Item -Path "C:\Tools" -ItemType Directory -Force

# enable RDP
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0

# Disable Defender and Firewall
Set-MpPreference -DisableRealtimeMonitoring $true
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Download the PowerUp script
$password = ConvertTo-SecureString "${proxy_pwd}" -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential("${proxy_user}", $password)
iwr -uri "https://raw.githubusercontent.com/plackyhacker/PowerUp/refs/heads/master/PowerUp.ps1" -OutFile "C:\\Tools\\PowerUp.ps1" -usebasicparsing -Proxy "http://172.31.245.222:8888" -ProxyCredential $creds

# Give everybody access to C:\Tools
$acl = Get-Acl "C:\Tools"
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.SetAccessRule($rule)
Set-Acl -Path "C:\Tools" -AclObject $acl

<# END FIRST BOOT CYCLE. START SECOND BOOT CYCLE #>
rcount_inc
Restart-Computer -Force
} elseif ($r -eq 1) { 
cred_init

# Unload the registry hive
reg unload "HKU\TempHive"

<# END CONTENT AUTHORING #>
