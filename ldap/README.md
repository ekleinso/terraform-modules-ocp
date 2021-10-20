# terraform-module-ocp-ldap
Configures an OpenShift cluster to use LDAP or MSAD for authentication

### Calling ldap module
```terraform
module "cluster_ldap" {
  source = "github.com/ekleinso/terraform-modules-ocp.git//ldap?ref=1.1"
  depends_on = []

  cluster_id = local.instance_id
  cluster_dir = format("%s/%s/installer", abspath(path.root), local.instance_id)

  ldap_server = "openldap.ocp.example.com"
  ldap_bind_dn = "cn=Manager"
  ldap_password = "********"
  ldap_type = "openldap"
  ldap_base_dn = "dc=ocp,dc=example,dc=com"
}
```