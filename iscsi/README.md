### Calling iscsi module
This module configures the iSCSI provisioner using [iscsi/targetd provisioner](https://github.com/kubernetes-retired/external-storage/tree/master/iscsi/targetd). It expects that the iSCSI target is configured and targetd is running. The provided link has good documentation on configuring the iSCSI server.

The configuration requires the WWN of all the iSCSI initiators. It is found in the **/etc/iscsi/initiatorname.iscsi** file on each node in the cluster. This information either needs to be collected from all the nodes or it is possible to update the initiator names on all the nodes using machine configs.

```terraform

module "cluster_iscsi_storage" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//iscsi?ref=1.1"

  depends_on = []

  cluster_id = "my_cluster_name"
  cluster_dir = format("%s/%s/installer", abspath(path.root), "my_cluster_name")

  storage_class = format("%s-block", "my_cluster_name")
  server = "192.168.0.9"
  port = "3260"
  volumegroup = "vg_targetd/thinpoollv"
  wwn = "iqn.2003-01.org.linux-iscsi.host:tgt1"
  initiators = "iqn.2003-01.org.linux-iscsi.host:master1,iqn.2003-01.org.linux-iscsi.host:master2,iqn.2003-01.org.linux-iscsi.host:master3,iqn.2003-01.org.linux-iscsi.host:worker1"

  user = "admin"
  password = "**********"
  is_default_class = "false"
}
```

#### terraform variables

| Variable                         | Description                                                  | Type   | Default |
| -------------------------------- | ------------------------------------------------------------ | ------ | ------- |
| cluster_id                   | The ID/Name of the cluster  | string | - |
| cluster_dir                  | The directory where the openshift-install command was executed. Should contain the auth folder username        | string | - |
| fstype                 | The filesystem to format the storage with. | string | ext4 |
| storage_class   | The name of the storage class to be created | string | iscsi |
| server          | Address/hostname for iSCSI server | string | - |
| port            | Port for iSCSI server     | string | 3260 |
| user            | Username for targetd server | string | - |
| password        | Password for targetd server | string | - |
| volumegroup     | LVM volume group or logical volume thin pool to carve LUNs | string | - |
| wwn             | World wide name for iSCSI server | string | - |
| initiators      | Comma delimitetd list of WWN for the iSCSI initiators (aka worker node wwn) | string | - |
| image          | Docker image to run the provisioner in OpenShift | string | quay.io/external_storage/iscsi-controller:latest |
| is_default_class | Should created storage class be the default | string | false |
