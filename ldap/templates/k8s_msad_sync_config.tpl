kind: LDAPSyncConfig
apiVersion: v1
url: ${ldap_host}
bindDN: ${bind_dn},cn=Users,${base_dn}
bindPassword: ${bind_password}
insecure: ${insecure}
${insecure ? "" : "ca: ${certificate}"}
groupUIDNameMapping:
  "cn=ocpGroup1,cn=Users,${base_dn}": msad-${cluster_name}-admins 
augmentedActiveDirectory:
    groupsQuery:
        baseDN: "ou=groups,${base_dn}"
        scope: sub
        derefAliases: never
        pageSize: 0
    groupUIDAttribute: dn 
    groupNameAttributes: [ cn ] 
    usersQuery:
        baseDN: "ou=users,${base_dn}"
        scope: sub
        derefAliases: never
        filter: (objectclass=organizationalPerson)
        pageSize: 0
    userNameAttributes: [ sAMAccountName ] 
    groupMembershipAttributes: [ memberOf ]
