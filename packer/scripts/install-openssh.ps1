$ErrorActionPreference = 'Stop'

Write-Host '>>> Installing OpenSSH Server (Windows Capability)...'
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Write-Host '>>> Installing OpenSSH Server (Windows Capability) completed'

Write-Host '>>> Starting OpenSSH Server...'
Start-Service -Name sshd
Set-Service -Name sshd -StartupType 'Automatic'
Write-Host '>>> Starting OpenSSH Server completed'

Write-Host '>>> Setting Windows Firewall for SSH...'
if (!(Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP')) {
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH SSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}
Set-NetFirewallRule -DisplayName 'OpenSSH SSH Server (sshd)' -Profile Any -Enabled True
Write-Host '>>> Setting Windows Firewall for SSH completed'

Write-Host '>>> Setting PowerShell 5.1 as SSH default shell...'
New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -PropertyType String -Force
New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShellCommandOption -Value '/c' -PropertyType String -Force
Restart-Service -Name sshd
Write-Host '>>> Setting PowerShell 5.1 as SSH default shell completed'
