kind: LDAPSyncConfig
apiVersion: v1
url: ${ldap_host}
bindDN: ${bind_dn},${base_dn}
bindPassword: ${bind_password}
insecure: ${insecure}
${insecure ? "" : "ca: ${certificate}"}
groupUIDNameMapping:
  "cn=cloudadmins,ou=groups,${base_dn}": ${cluster_name}-Admins
  "cn=cloudgrp,ou=groups,${base_dn}": ${cluster_name}-Users
rfc2307:
    groupsQuery:
        baseDN: "ou=groups,${base_dn}"
        filter: (objectClass=groupOfNames)
        scope: sub
        derefAliases: never
        pageSize: 0
    groupUIDAttribute: dn
    groupNameAttributes: [ cn ]
    groupMembershipAttributes: [ member ]
    usersQuery:
        baseDN: "ou=users,${base_dn}"
        scope: sub
        derefAliases: never
        pageSize: 0
    userUIDAttribute: dn
    userNameAttributes: [ uid ]
    tolerateMemberNotFoundErrors: false
    tolerateMemberOutOfScopeErrors: false
