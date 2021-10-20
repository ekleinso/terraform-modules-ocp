# terraform-module-wait-for

### Calling wait-for module
```terraform
module "wait_for_bootstrap" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//wait-for?ref=1.1"

  depends_on = []

  cluster_id = var.cluster_id
  cluster_dir = format("%s/installer/%s", path.root, var.cluster_id)

  what_for = "bootstrap-complete"
}

module "wait_for_install" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//wait-for?ref=1.1"

  depends_on = [module.wait_for_bootstrap]

  cluster_id = var.cluster_id
  cluster_dir = format("%s/installer/%s", path.root, var.cluster_id)

  what_for = "install-complete"
}
```