# terraform-module-wait-for
This module provides the ability to wait for the cluster to achieve a defined state, for example **bootstrap-complete**, **install-complete** and **operators**.

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

module "wait_for_operators" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//wait-for?ref=1.1"

  depends_on = [module.wait_for_bootstrap]

  cluster_id = var.cluster_id
  cluster_dir = format("%s/installer/%s", path.root, var.cluster_id)

  what_for = "operators"
}
```

#### terraform variables

| Variable                         | Description                                                  | Type   | Default |
| -------------------------------- | ------------------------------------------------------------ | ------ | ------- |
| cluster_id      | The ID/Name of the cluster                                       | string | - |
| cluster_dir     | The directory where the openshift-install command was executed. Should contain the auth folder username        | string | - |
| what_for   | Status to wait for **(bootstrap-complete, install-complete and operators)** | string | - |
| log_level    | Log level (e.g. "debug | info | warn | error") | string | info |
