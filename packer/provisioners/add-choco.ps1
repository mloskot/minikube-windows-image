$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

Write-Host '>>> Installing Chocolatey...'

Set-ExecutionPolicy Bypass -Scope Process -Force;
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Bypass confirmation prompts
choco feature enable --name=allowGlobalConfirmation

# Avoid exit code 3010 (ERROR_SUCCESS_REBOOT_REQUIRED) which fails Packer pipeline
# https://github.com/chocolatey/choco/issues/3087#issuecomment-1552742454
choco feature disable --name=usePackageExitCodes

# Ignore any detected reboots
choco feature disable --name=exitOnRebootDetected

Write-Host '>>> Installing Chocolatey done'
