# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Enable Hyper-V and Containers (Required for Docker Desktop)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
wsl --install

# -------------------------

# Install tools
choco install docker-desktop -y --no-progress
choco install golang -y --no-progress
choco install caffeine -y --no-progress
choco install git -y --no-progress
choco install gh -y --no-progress
choco install jq -y --no-progress
choco install make -y --no-progress
choco install grep -y --no-progress
choco install sed -y --no-progress
choco install gawk -y --no-progress
choco install diffutils -y --no-progress
choco install findutils -y --no-progress
choco install kubernetes-cli -y --no-progress

# --- UI & Startup Configuration ---
# Write-Host "Configuring UI and Startup..."

# 2. Create Startup Shortcuts
$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$wsh = New-Object -ComObject WScript.Shell

# Caffeine Startup
$caffeinePath = "C:\ProgramData\chocolatey\bin\caffeine64.exe"
if (Test-Path $caffeinePath) {
    $sc = $wsh.CreateShortcut("$startupPath\Caffeine.lnk")
    $sc.TargetPath = $caffeinePath
    $sc.WindowStyle = 7 # Minimized/Hidden
    $sc.Save()
}

# Start Caffeine to prevent sleep
if (Test-Path "C:\ProgramData\chocolatey\bin\caffeine.exe") {
    Start-Process "C:\ProgramData\chocolatey\bin\caffeine64.exe" -WindowStyle Hidden
}

# Docker Desktop Startup (Backup assurance)
# $dockerPath = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
# if (Test-Path $dockerPath) {
#     $sc = $wsh.CreateShortcut("$startupPath\Docker Desktop.lnk")
#     $sc.TargetPath = $dockerPath
#     $sc.Save()
# }
# -------------------------

# Add Git usr/bin to PATH for common Unix tools (grep, cut, uname, etc.)
# Prepend Git usr/bin to PATH so Unix tools (find, sort, etc.) take precedence over Windows tools
$gitUnixPath = "C:\Program Files\Git\usr\bin"
if (!(Test-Path $gitUnixPath)) {
    Write-Warning "Git Unix tools not found at $gitUnixPath. Check Git installation."
} else {
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($currentPath -notlike "*$gitUnixPath*") {
        Write-Host "Prepending $gitUnixPath to Machine PATH..."
        [Environment]::SetEnvironmentVariable("Path", "$gitUnixPath;$currentPath", "Machine")
        $env:Path = "$gitUnixPath;$env:Path"
    } elseif ($currentPath.IndexOf($gitUnixPath) -gt 0) {
        Write-Host "Moving $gitUnixPath to the start of Machine PATH..."
        $newPath = $currentPath.Replace(";$gitUnixPath", "").Replace("$gitUnixPath;", "")
        [Environment]::SetEnvironmentVariable("Path", "$gitUnixPath;$newPath", "Machine")
        $env:Path = "$gitUnixPath;" + $env:Path.Replace(";$gitUnixPath", "").Replace("$gitUnixPath;", "")
    }
}

# 3. Persist via PowerShell Profile (for future sessions)
$profilePath = $PROFILE.CurrentUserAllHosts
if (!(Test-Path $profilePath)) {
    New-Item -Path $profilePath -ItemType File -Force | Out-Null
}
$profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue

# Git Path Fix
if ($null -eq $profilePath) { $profilePath = $PROFILE.CurrentUserAllHosts }
$pathFixCmd = '$env:Path = "C:\Program Files\Git\usr\bin;" + $env:Path.Replace("C:\Program Files\Git\usr\bin;", "")'
if ($profileContent -notlike "*$pathFixCmd*") {
    Add-Content -Path $profilePath -Value "`n# Prioritize Git Unix tools`n$pathFixCmd"
}
 
# Install OpenSSH Server (Windows Capability)
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Start and Configure SSH Service
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

Write-Host "Installation complete. Please reboot the VM for Docker Desktop groups to apply."
Write-Host "IMPORTANT: You MUST close and reopen your PowerShell window for PATH changes (Unix tools) to take effect." -ForegroundColor Red
