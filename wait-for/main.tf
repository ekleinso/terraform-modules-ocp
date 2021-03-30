locals {
  cluster_dir = var.cluster_dir == "" ? format("%s/installer/%s", path.root, var.cluster_id) : var.cluster_dir 
}

resource "null_resource" "wait_for" {

  provisioner "local-exec" {
    command = <<EOF
set -ex
if [ "${var.what_for}" == "operators" ]; then
  ${path.module}/scripts/wait_for_operator.sh
else
  binaries/openshift-install --dir=. wait-for ${var.what_for} --log-level ${var.log_level}
fi
EOF
  
    working_dir = local.cluster_dir
  }

}

