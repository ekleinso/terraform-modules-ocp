data "template_file" "lvm_config" {
  template = <<EOF
{
  "systemd": {
    "units": [
      {
        "contents": "# Create LVM for openebs at boot\n[Unit]\nDocumentation=https://github.com/openebs/lvm-localpv\n\n[Service]\nType=oneshot\nExecStart=/usr/bin/sh -c 'test -b ${var.pv} && pvcreate ${var.pv} && vgcreate ${var.volgroup}'\nRemainAfterExit=yes\n[Install]\nWantedBy=multi-user.target",
        "enabled": true,
        "name": "openebs-create-vg.service"
      }
    ]
  }
}
EOF
}

data "template_file" "openebs_sc" {
  template = <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ${var.storage_class}
allowVolumeExpansion: true
parameters:
  volgroup: "${var.volgroup}"
provisioner: local.csi.openebs.io
EOF
}

data "template_file" "openebs_scc" {
  template = <<EOF
allowHostDirVolumePlugin: true
allowHostIPC: true
allowHostNetwork: true
allowHostPID: true
allowHostPorts: true
allowPrivilegeEscalation: true
allowPrivilegedContainer: true
allowedCapabilities:
- '*'
allowedUnsafeSysctls:
- '*'
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: 'privileged allows access to all privileged and host
      features and the ability to run as any user, any group, any fsGroup, and with
      any SELinux context.  WARNING: this is the most relaxed SCC and should be used
      only for cluster administration. Grant with caution.'
  name: openebs-privileged
defaultAddCapabilities: null
fsGroup:
  type: RunAsAny
groups:
- system:cluster-admins
- system:nodes
- system:masters
priority: null
readOnlyRootFilesystem: false
requiredDropCapabilities: null
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: RunAsAny
seccompProfiles:
- '*'
supplementalGroups:
  type: RunAsAny
users:
- system:serviceaccount:openebs:openebs-lvm-node-sa
volumes:
- '*'
EOF
}

resource "null_resource" "openebs" {
  provisioner "local-exec" {
    command = <<EOF
set -ex

curl -s https://raw.githubusercontent.com/openebs/lvm-localpv/master/deploy/lvm-operator.yaml | sed -e 's/kube-system/openebs/' | binaries/oc apply -f -

echo "${data.template_file.openebs_sc.rendered}" | binaries/oc apply -f -
echo "${data.template_file.openebs_scc.rendered}" | binaries/oc apply -f -

EOF

    environment = {
      KUBECONFIG  = format("%s/auth/kubeconfig", var.cluster_dir)
    }

    working_dir = var.cluster_dir
  }

}

