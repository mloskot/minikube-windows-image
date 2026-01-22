build {
  sources = [
    "source.azure-arm.minikube-windows-11"
  ]

  ###### <Provisioners with elevated privileges>
  # These provisioners are required for DISM (e.g. install OpenSSH) and other actions,
  # and are implemented in terms scheduled tasks which require AutoLogon to complete.
  provisioner "powershell" {
    script = "scripts/enable-autologon.ps1"
    environment_vars = [
      "AUTOLOGON_USER_PASSWORD=${var.vm_admin_password}"
    ]
  }

  provisioner "windows-restart" {}

  provisioner "powershell" {
    elevated_user     = var.vm_admin_username
    elevated_password = var.vm_admin_password
    scripts = [
      "scripts/disable-privacy.ps1"
      # "scripts/disable-services.ps1",
      # "scripts/optimize-windows.ps1",
      # "scripts/install-openssh.ps1"
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
