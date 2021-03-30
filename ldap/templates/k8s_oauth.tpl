apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - ldap:
      attributes:
        email: []
        id:
        - dn
        name:
        - cn
        preferredUsername:
        - uid
      bindDN: ${bind_dn},${base_dn}
      bindPassword:
        name: ldap-bind-password-${cluster_name}
      insecure: ${insecure}
      url: ${ldap_host}/${base_dn}?uid?sub?(objectClass=*)
      ${insecure ? "" : "ca:\n        name: ${certificate}"}
    mappingMethod: claim
    name: openldap
    type: LDAP
