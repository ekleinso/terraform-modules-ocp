# terraform-module-ocp-nfs-client
Configures the opensource [nfs subdir provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner) as a dynamic storage provider providing a RWX storage class

### Calling nfs-client module
```terraform
module "cluster_nfs_client_storage" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//nfs-client?ref=1.1"

  depends_on = []

  cluster_id = "my_cluster_name"
  cluster_dir = format("%s/%s/installer", abspath(path.root), "my_cluster_name")

  storage_class = "nfs-client-file"
  nfs_server = "192.168.0.9"
  nfs_server_path = "/repository/kubevols"
  is_default_class = "false"
}
```

#### terraform variables

| Variable                         | Description                                                  | Type   | Default |
| -------------------------------- | ------------------------------------------------------------ | ------ | ------- |
| cluster_id      | The ID/Name of the cluster                                       | string | - |
| cluster_dir     | The directory where the openshift-install command was executed. Should contain the auth folder username        | string | - |
| storage_class   | Storage class name for the provisioner | string | nfs-client |
| nfs_server    | Address/hostname for NFS server | string | - |
| nfs_server_path   | NFS Server path | string | - |
| image       | Docker image to run the provisioner   | string | quay.io/external_storage/nfs-client-provisioner:v3.1.0-k8s1.11 |
| is_default_class    | Should created storage class be the default | string | false |
