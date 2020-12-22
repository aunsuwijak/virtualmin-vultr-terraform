terraform {
  required_providers {
    vultr = {
      source = "vultr/vultr"
      version = "2.1.1"
    }
  }
}

provider "vultr" {
  api_key = var.vultr_api_key
}

resource "vultr_instance" "web" {
  plan = var.vultr_plan
  region = var.vultr_region
  os_id = var.vultr_os_id
  label = var.vultr_label
  hostname = var.vultr_hostname
  ssh_key_ids = var.vultr_ssh_key_ids
}

resource "null_resource" "virtualmin" {
  connection {
    user         = "root"
    host         = vultr_instance.web.main_ip
    private_key  = file(var.ssh_private_key_path)
  }
  provisioner "remote-exec" {
    inline = [
      "curl http://software.virtualmin.com/gpl/scripts/install.sh -o /root/install.sh",
      "chmod 755 install.sh",
      "~/install.sh --force --hostname ${var.virtualmin_hostname} --yes",
      "rm -f /root/install.sh"
    ]
  }
}
