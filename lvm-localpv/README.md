# terraform-module-lvm-localpv
Configures the opensource [OpenEBS project](https://openebs.io/docs/) as a dynamic storage provider providing a RWO storage class using available block storage and LVM.

### Calling nfs-client module
```terraform
locals {
  pv = "/dev/vdb"
  volgroup = "openebsvg"
  roles = ["master", "worker"]
}

data "template_file" "lvm_config" {
  count = length(local.roles)
  template = <<EOF
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: ${element(local.roles, count.index)}
  name: 99-${element(local.roles, count.index)}-openebs-create-vg
spec:
  config:
    ignition:
      version: 3.2.0
    systemd:
      units:
      - name: openebs-create-vg.service
        enabled: true
        contents: "# Create LVM for openebs at boot\n[Unit]\nDocumentation=https://github.com/openebs/lvm-localpv\n\n[Service]\nType=oneshot\nExecStart=/usr/bin/sh -c 'test -b ${local.pv} && pvcreate ${local.pv} && vgcreate ${local.volgroup} ${local.pv} || (exit 0)'\nRemainAfterExit=yes\n[Install]\nWantedBy=multi-user.target"
EOF
}

resource "local_file" "lvm_openebs" {
  count = length(local.roles)
  lifecycle {
    ignore_changes = [content]
  }
  content  = element(data.template_file.lvm_config.*.rendered, count.index)
  filename = format("%s/%s/cluster_configs/99_%s-openebs-create-vg.yaml", path.module, local.instance_id, element(local.roles, count.index))
  file_permission = 644
}

module "cluster_openebs_storage" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//lvm-localpv?ref=1.2"

  depends_on = [
    null_resource.create_cluster
  ]

  cluster_dir = format("%s/%s/installer", abspath(path.root), local.instance_id)

}
```

#### terraform variables

| Variable                         | Description                                                  | Type   | Default |
| -------------------------------- | ------------------------------------------------------------ | ------ | ------- |
| cluster_dir     | The directory where the openshift-install command was executed. Should contain the auth folder username        | string | - |
| storage_class   | Storage class name for the provisioner | string | openebs-lvmsc |
| volgroup    | Name of the LVM volume group to create/use | string | openebsvg |
| pv   | Name of the physical volume | string | /dev/vdb |
| is_default_class    | Should created storage class be the default | string | false |
