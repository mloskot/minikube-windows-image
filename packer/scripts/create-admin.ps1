$ErrorActionPreference = 'Stop'

Write-Output '>>> Creating local administrator user...'

if ([string]::IsNullOrEmpty($env:ADMIN_USERNAME)) { throw 'env:ADMIN_USERNAME must be set' }
if ([string]::IsNullOrEmpty($env:ADMIN_PASSWORD)) { throw 'env:ADMIN_PASSWORD must be set' }

Write-Output ">>> username: $env:ADMIN_USERNAME"
Write-Output ">>> password: $env:ADMIN_PASSWORD"

$password = ConvertTo-SecureString "$env:ADMIN_PASSWORD" -AsPlainText -Force
New-LocalUser -Name $env:ADMIN_USERNAME -Password $password -FullName $env:ADMIN_USERNAME -Description 'Minikube Administrator' -AccountNeverExpires -PasswordNeverExpires
Add-LocalGroupMember -Group 'Administrators' -Member $env:ADMIN_USERNAME -ErrorAction SilentlyContinue

Write-Output '>>> Creating local administrator user completed'
