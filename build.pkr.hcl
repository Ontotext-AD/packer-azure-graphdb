build {
  sources = [
    "source.azure-arm.ubuntu-x86-64"
  ]

  provisioner "file" {
    sources = [
      "./files/graphdb.env",
      "./files/graphdb.service",
      "./files/graphdb-cluster-proxy.env",
      "./files/graphdb-cluster-proxy.service",
      "./files/graphdb_backup"
    ]
    destination = "/tmp/"
  }

  provisioner "shell" {
    environment_vars = [
      "GRAPHDB_VERSION=${var.graphdb_version}",
    ]
    execute_command = "{{ .Vars }} sudo -E bash '{{ .Path }}'"
    scripts = [
      "./files/1-setup.sh",
      "./files/2-hardening.sh",
      "./files/3-install-graphdb.sh",
    ]
    max_retries = var.build_retries
  }

  provisioner "breakpoint" {
    disable = !var.build_breakpoint_enabled
    note    = "Paused for debugging — SSH in now"
  }

  # https://developer.hashicorp.com/packer/integrations/hashicorp/azure/latest/components/builder/arm#deprovision
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
    inline = [
      "/usr/sbin/waagent -force -deprovision && export HISTSIZE=0 && sync"
    ]
    inline_shebang = "/bin/sh -x"
  }

  post-processor "manifest" {
    output = var.manifest_path
    custom_data = {
      graphdb_version = var.graphdb_version
    }
  }
}
