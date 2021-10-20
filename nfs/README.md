# terraform-module-ocp-nfs
This module configures a file base storage provisioner using the opensource [nfs ganesha provisioner](https://github.com/kubernetes-sigs/nfs-ganesha-server-and-external-provisioner) 

### Calling nfs module
```terraform
module "cluster_nfs_storage" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//nfs?ref=1.1"

  depends_on = []

  cluster_id = "my_cluster_name"
  cluster_dir = format("%s/installer/%s", abspath(path.root), "my_cluster_name")

  storage_class = "nfs-file"
  pvc_storage_class = "thin"
  pvc_size = "100G"
  is_default_class = "true"
}
```

#### terraform variables

| Variable                         | Description                                                  | Type   | Default |
| -------------------------------- | ------------------------------------------------------------ | ------ | ------- |
| cluster_id      | The ID/Name of the cluster                                       | string | - |
| cluster_dir     | The directory where the openshift-install command was executed. Should contain the auth folder username        | string | - |
| storage_class   | Storage class name for the provisioner | string | nfs |
| pvc_storage_class    | Storage class name to be used to create backing storage for provisioner | string | thin |
| pvc_size   | Size of the volume to create as backing storage for provisioner | string | 500G |
| image       | Docker image to run the provisioner   | string | quay.io/kubernetes_incubator/nfs-provisioner:latest |
| is_default_class    | Should created storage class be the default | string | false |
