# terraform-module-ocp-nfs-client

### Calling nfs-client module
```terraform
locals {
  nfs_server = "192.168.0.9"
  nfs_server_path = "/repository/kubevols"
}

module "cluster_nfs_client_storage" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//nfs-client?ref=1.1"

  depends_on = []

  cluster_id = local.instance_id
  cluster_dir = format("%s/%s/installer", abspath(path.root), local.instance_id)

  storage_class = format("%s-file", local.instance_id)
  nfs_server = local.nfs_server
  nfs_server_path = local.nfs_server_path
  is_default_class = "false"
}
```