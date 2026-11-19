build {
  sources = [
    "source.azure-arm.ubuntu-x86-64"
  ]

  provisioner "file" {
    sources = [
      "./files/graphdb.env",
      "./files/graphdb.service",
      "./files/graphdb-cluster-proxy.service",
      "./files/install_graphdb.sh",
      "./files/graphdb_backup"
    ]
    destination = "/tmp/"
  }

  provisioner "shell" {
    environment_vars = [
      "GRAPHDB_VERSION=${var.graphdb_version}",
    ]
    # On Ubuntu 25.10+ "sudo" is sudo-rs, which ignores -E, so the var is passed as a sudo argument
    inline      = ["sudo GRAPHDB_VERSION=\"$GRAPHDB_VERSION\" bash /tmp/install_graphdb.sh"]
    max_retries = 2
  }

  # https://developer.hashicorp.com/packer/integrations/hashicorp/azure/latest/components/builder/arm#deprovision
  provisioner "shell" {
    # On Ubuntu 25.10+ "sudo" is sudo-rs, which drops the caller env even with -E, so vars are passed as sudo arguments
    execute_command = "chmod +x {{ .Path }}; sudo {{ .Vars }} sh '{{ .Path }}'"
    inline = [
      "/usr/sbin/waagent -force -deprovision && export HISTSIZE=0 && sync"
    ]
    inline_shebang = "/bin/sh -x"
  }
}
