### Calling htpasswd module
This module configures the HTPasswd identity provider enabling a simple local login for when kubeadmin is removed.

```terraform
module "cluster_htpasswd" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//htpasswd?ref=1.1"
  depends_on = []

  cluster_dir = format("%s/%s/installer", abspath(path.root), local.instance_id)

  password = "********"
  user = "ocpadmin"
}
```
#### terraform variables

| Variable                         | Description                                                  | Type   | Default |
| -------------------------------- | ------------------------------------------------------------ | ------ | ------- |
| password                 | The password for the specified user. | string | "" |
| random_password_length   | If a password is not specified a random password will be generated using the length specified here | number | 24 |
| user                      | The user to specifiy for htpasswd | string | ocpadmin |
| cluster_dir                  | The directory where the openshift-install command was executed. Should contain the auth folder username. The password will be copied to a file here <username>-password     | string | - |
