# terraform-module-ocp-nfs

### Calling nfs module
```terraform
module "cluster_nfs_storage" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//nfs?ref=1.1"

  depends_on = []

  cluster_id = var.cluster_id
  cluster_dir = format("%s/installer/%s", abspath(path.root), var.cluster_id)

  storage_class = "nfs"
  pvc_storage_class = "thin"
  pvc_size = "100G"
  is_default_class = "true"
}
```