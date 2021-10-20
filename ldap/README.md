# terraform-module-ocp-ldap
Configures an OpenShift cluster to use LDAP or MSAD for an oAuth identity provider

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

#### terraform variables

| Variable                         | Description                                                  | Type   | Default |
| -------------------------------- | ------------------------------------------------------------ | ------ | ------- |
| cluster_id      | The ID/Name of the cluster                                       | string | - |
| cluster_dir     | The directory where the openshift-install command was executed. Should contain the auth folder username        | string | - |
| ldap_server     | IP address or hostname of ldap/msad server | string | - |
| ldap_bind_dn    | bind DN to connect to ldap/msad will be combined with baseDN | string | - |
| ldap_password   | bind password to connect to ldap/msad | string | - |
| ldap_type       | type of ldap server openldap or msad    | string | - |
| ldap_base_dn    | base DN for ldap/msad | string | - |
| ldap_certificate  | Certificate for ldap/msad server if TLS is required and using self-signed cert | string | - |
| msad_whitelist  | Whitelist file for MSAD group synchronization | string | - |
