$ErrorActionPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'

# https://minikube.sigs.k8s.io/docs/tutorials/docker_desktop_replacement/#Windows
Write-Host '>>> Installing Hyper-V...'

# Ignore package exit code 3010 (ERROR_SUCCESS_REBOOT_REQUIRED)
choco install Containers Microsoft-Hyper-V --source windowsfeatures --yes --no-prompt --ignore-package-exit-codes --ignore-detected-reboot

Write-Host '>>> Installing Hyper-V done'

# Paranoid mode: ignore exit code 3010 (ERROR_SUCCESS_REBOOT_REQUIRED)
exit 0
