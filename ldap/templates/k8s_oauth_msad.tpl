apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - ldap:
      attributes:
        email:
        - mail
        id:
        - dn
        name:
        - cn
        preferredUsername:
        - sAMAccountName
      bindDN: ${bind_dn},cn=Users,${base_dn}
      bindPassword:
        name: ldap-bind-password-${cluster_name}
      insecure: ${insecure}
      url: ${ldap_host}/${base_dn}?sAMAccountName?sub
      ${insecure ? "" : "
      ca:
        name: custom-ca
"}
    mappingMethod: claim
    name: msad
    type: LDAP
