build {
  sources = [
    "source.azure-arm.mk-win11"
  ]

  ###### <Provisioners with elevated privileges>
  # These provisioners are required for DISM (e.g. install OpenSSH) and other actions,
  # and are implemented in terms scheduled tasks which require AutoLogon to complete.
  provisioner "powershell" {
    script = "scripts/enable-autologon.ps1"
    environment_vars = [
      "AUTOLOGON_USER_PASSWORD=${var.admin_password}"
    ]
  }

  provisioner "windows-restart" {}

  provisioner "powershell" {
    elevated_user     = var.admin_username
    elevated_password = var.admin_password
    scripts = [
      "scripts/disable-privacy.ps1",
      "scripts/disable-services.ps1",
      "scripts/optimize-windows.ps1",
      "scripts/install-openssh.ps1"
    ]
  }

  provisioner "powershell" {
    script = "scripts/disable-autologon.ps1"
  }
  ###### </Provisioners with elevated privileges>

  # provisioner "powershell" {
  #   script = "scripts/install-tools.ps1"
  # }
}
