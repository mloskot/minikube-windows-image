$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

# https://minikube.sigs.k8s.io/docs/tutorials/docker_desktop_replacement/#Windows
Write-Host '>>> Installing Docker Engine...'

if (-not (Get-Service -Name vmic*)) {
    Write-Error "add-docker.ps1 must run after add-hyperv.ps1" -ErrorAction Stop
}

# Ignore package exit code 3010 (ERROR_SUCCESS_REBOOT_REQUIRED)
choco install docker-engine --yes --no-prompt --ignore-package-exit-codes --ignore-detected-reboot

Write-Host '>>> Installing Docker Engine done'

# Paranoid mode: ignore exit code 3010 (ERROR_SUCCESS_REBOOT_REQUIRED)
exit 0
