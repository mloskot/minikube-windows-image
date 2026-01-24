$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

Write-Host '>>> Installing other tools...'

# TODO:
choco install golang --yes --no-prompt --ignore-package-exit-codes --ignore-detected-reboot
choco install jq --yes --no-prompt --ignore-package-exit-codes --ignore-detected-reboot
choco install git --yes --no-prompt --ignore-package-exit-codes --ignore-detected-reboot

# Reload PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

go install github.com/medyagh/gopogh/cmd/gopogh@latest

Write-Host '>>> Installing other tools done'
